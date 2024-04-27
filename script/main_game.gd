extends Control


# pixel scene
@export var pixel_ins:PackedScene
@export var menu_new_game:Button
@export var player_turn:Sprite2D
@export var player_win:Sprite2D
@export var move_label:Label

# hien thi kieu danh dau x, o
@export var marker_o:PackedScene
@export var marker_x:PackedScene

# du lieu game: xem trong script data
@export var data:Node

var game_end:bool = false
var team_select:int = 1
var map_size:int = 10
# lua tru toa do, vi tri cua cac diem pixel
var board_data:Array
# lua tru cac diem pixel
var pixel_board:Array
var pixel_x:Array = [0,1080]
var pixel_y:Array = [0,720]
# tất cả các lượt đánh:
var all_moves:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_new_game.connect("pressed",on_new_game)
	# tao data dua vao kich thuoc man hinh xac dinh hoac tuy chon x = 17, y = 11
	for i in round(size.y/64):
		board_data.append([])
		for j in round(size.x/64):
			board_data[i].append(0)
	pixel_board = board_data.duplicate(true)
	# them vao cac diem pixel dua data co duoc o tren
	for i in board_data.size():
		for j in board_data[i].size():
			var pixel:Sprite2D = pixel_ins.instantiate()
			$Board.add_child(pixel)
			if j == 0:
				pixel.position.x = 32
				pixel_board[i][0] = pixel
			else:
				pixel.position.x = 32 + j * 64
				pixel_board[i][j] = pixel
			#pixel.get_child(0).frame = i
			#pixel.get_child(1).frame = j
			pixel.get_child(0).hide()
			pixel.get_child(1).hide()
			pixel.position.y = 32 + i * 64
			if i < map_size and j < map_size:
				pixel.modulate = Color.WHITE
			else:
				pixel.modulate = Color.BLACK
	on_new_game()

func _input(event):
	if event is InputEventMouseButton and game_end == false:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if (event.position.x > pixel_x[0] and event.position.x < pixel_x[1]
			and event.position.y > pixel_y[0] and event.position.y < pixel_y[1]):
				prints("event.position",event.position)
				add_marker(event.position)
	if Input.is_key_label_pressed(KEY_ESCAPE):
		prints("check_win",check_win())

func add_marker(pos):
	var x:int = (pos.x)/64
	var y:int = (pos.y-$Board.position.y)/64
	var node:Sprite2D = $Board.get_child(x+(y*board_data[0].size()))
	if node.modulate == Color.WHITE and board_data[y][x] == 0:
		all_moves += 1
		move_label.text = "Moves: " + str(all_moves)
		board_data[y][x] = team_select
		var marker:Sprite2D
		if team_select == 1:
			marker = marker_o.instantiate()
		else:
			marker = marker_x.instantiate()
		$Marker.add_child(marker)
		marker.position = node.position
		if check_win() == 0:
			change_team()
		else:
			on_game_end(check_win())

func change_team():
	if team_select == 1:
		player_turn.frame = 1
		player_turn.self_modulate = Color.RED
		team_select = -1
	else:
		player_turn.frame = 0
		player_turn.self_modulate = Color.GREEN
		team_select = 1

func get_pixel(board_pos:Array) -> Sprite2D:
	var x:int = board_pos[1]
	var y:int = board_pos[0]
	var pixel:Sprite2D = $Board.get_child(x+(y*board_data[0].size()))
	return pixel

func on_new_game():
	team_select = 1
	all_moves = 0
	player_turn.frame = 0
	player_turn.self_modulate = Color.GREEN
	player_win.frame = 0
	player_win.self_modulate = Color.GREEN
	board_data = []
	move_label.text = "Moves: " + str(all_moves)
	for i in round(size.y/64):
		board_data.append([])
		for j in round(size.x/64):
			board_data[i].append(0)
	if $Marker.get_child_count() > 0:
		for child in $Marker.get_children():
			child.queue_free()
	menu_new_game.hide()
	game_end = false

func on_game_end(team_win:int = 1):
	game_end = true
	if team_win == 1:
		player_win.frame = 0
		player_win.self_modulate = Color.GREEN
	else:
		player_win.frame = 1
		player_win.self_modulate = Color.RED
	await get_tree().create_timer(0.5,false).timeout
	menu_new_game.show()

func check_win() -> int:
	var count = 0
	var markers:Array
	for i in board_data.size():
		for j in board_data[i].size():
			if board_data[i][j] == team_select:
				markers.append([j,i])
	prints("markers",markers, team_select)
	
	for n in markers.size():
		var marker = markers[n]
		var x = marker[0]
		var y = marker[1]
		# Kiểm tra các hàng
		if !x in [0,map_size-1]:
			if board_data[y][x-1] == team_select and board_data[y][x+1] == team_select:
				prints("Check Horizontal", marker)
				# Kiểm tra có bị chặn ko
				if x-2 < 0 and x+2 > map_size-1:
					prints("Map block all", marker)
					return team_select
				elif x-2 >= 0 and x+2 > map_size-1:
					prints("Map block left", marker)
					if board_data[y][x-2] == 0 or board_data[y][x-2] == team_select:
						return team_select
				elif x-2 < 0 and x+2 <= map_size-1:
					prints("Map block right", marker)
					if board_data[y][x+2] == 0 or board_data[y][x+2] == team_select:
						return team_select
				elif x-2 >= 0 and x+2 <= map_size-1:
					prints("Map no block", marker)
					if board_data[y][x-2] == 0 and board_data[y][x+2] == 0:
						return team_select
					elif board_data[y][x-2] != 0:
						prints("Check left", marker)
						if board_data[y][x+2] == team_select:
							return team_select
					elif board_data[y][x+2] != 0:
						prints("Check right", marker)
						if board_data[y][x-2] == team_select:
							return team_select
		# Kiểm tra các cột
		if !y in [0,map_size-1]:
			if board_data[y-1][x] == team_select and board_data[y+1][x] == team_select:
				# Kiểm tra có bị chặn ko
				prints("Check Vertical", marker)
				if y-2 < 0 and y+2 > map_size-1:
					prints("Map block all", marker)
					return team_select
				elif y-2 >= 0 and y+2 > map_size-1:
					prints("Map block left", marker)
					if board_data[y-2][x] == 0 or board_data[y-2][x] == team_select:
						return team_select
				elif y-2 < 0 and y+2 <= map_size-1:
					prints("Map block right", marker)
					if board_data[y+2][x] == 0 or board_data[y+2][x] == team_select:
						return team_select
				elif y-2 >= 0 and y+2 <= map_size-1:
					prints("Map no block", marker)
					if board_data[y-2][x] == 0 and board_data[y+2][x] == 0:
						return team_select
					if board_data[y-2][x] != 0:
						prints("Check left", marker)
						if board_data[y+2][x] == team_select:
							return team_select
					if board_data[y+2][x] != 0:
						prints("Check right", marker)
						if board_data[y-2][x] == team_select:
							return team_select
		# Kiểm tra các đường chéo
		if !x in [0,map_size-1] and !y in [0,map_size-1]:
			prints("Check Diagonal")
			# Đường chéo trái-phải
			if board_data[y-1][x-1] == team_select and board_data[y+1][x+1] == team_select:
				prints("Left Diagonal", marker)
				# Kiểm tra có bị chặn ko
				if (y-2<0 and x-2<0) and (y+2>map_size-1 and x+2>map_size-1):
					prints("Map block all", marker)
					return team_select
				elif (y-2>=0 and x-2>=0) and (y+2>map_size-1 and x+2>map_size-1):
					prints("Map block Left", marker)
					if board_data[y-2][x] == 0 or board_data[y-2][x] == team_select:
						return team_select
				elif (y-2<0 and x-2<0) and (y+2<=map_size-1 and x+2<=map_size-1):
					prints("Map block Right", marker)
					if board_data[y+2][x] == 0 or board_data[y+2][x] == team_select:
						return team_select
				elif (y-2>=0 and x-2>=0) and (y+2<=map_size-1 and x+2<=map_size-1):
					prints("Map no block", marker)
					if board_data[y-2][x-2] == 0 and board_data[y+2][x+2] == 0:
						prints("Check center", marker)
						return team_select
					elif board_data[y-2][x-2] != 0:
						prints("Check left", marker)
						if board_data[y+2][x+2] == team_select:
							return team_select
					elif board_data[y+2][x+2] != 0:
						prints("Check right", marker)
						if board_data[y-2][x-2] == team_select:
							return team_select
			# Đường chéo phải-trái
			if board_data[y-1][x+1] == team_select and board_data[y+1][x-1] == team_select:
				#(board[y-2][x+2] == 0 and board[y+2][x-2] == 0)
				prints("Right Diagonal", marker)
				# Kiểm tra có bị chặn ko
				if (y-2<0 and x+2>map_size-1) and (y+2>map_size-1 and x-2<0):
					prints("Map block all", marker)
					return team_select
				elif (y-2<0 and x+2>map_size-1) and (y+2<=map_size-1 and x-2>=0):
					prints("Map block Top", marker)
					if board_data[y+2][x-2] == 0 or board_data[y+2][x-2] == team_select:
						return team_select
				elif (y-2>=0 and x+2<=map_size-1) and (y+2>map_size-1 and x-2<0):
					prints("Map block Down", marker)
					if board_data[y-2][x+2] == 0 or board_data[y-2][x+2] == team_select:
						return team_select
				elif (y-2>=0 and x+2<=map_size-1) and (y+2<=map_size-1 and x-2>=0):
					prints("Map no block", marker)
					if board_data[y-2][x+2] == 0 and board_data[y+2][x-2] == 0:
						prints("Check center", marker)
						return team_select
					if board_data[y-2][x+2] != 0:
						prints("Check left", marker)
						if board_data[y+2][x-2] == team_select:
							return team_select
					elif board_data[y+2][x-2] != 0:
						prints("Check right", marker)
						if board_data[y-2][x+2] == team_select:
							return team_select
	return 0
