extends Control


# pixel scene
@export var pixel_ins:PackedScene

# hien thi kieu danh dau x, o
@export var marker_o:PackedScene
@export var marker_x:PackedScene

# hien thi diem dat duoc
@export var score_label:Label
@export var high_score_label:Label
@export var your_score_label:Label
# du lieu game: xem trong script data
@export var data:Node

var team_select:int = 1
var map_size:int = 5
# lua tru toa do, vi tri cua cac diem pixel
var board:Array
# lua tru cac diem pixel
var pixel_board:Array
var pixel_x:Array = [0,1080]
var pixel_y:Array = [0,720]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# tao data dua vao kich thuoc man hinh xac dinh hoac tuy chon x = 17, y = 11
	for i in round(size.y/64):
		board.append([])
		for j in round(size.x/64):
			board[i].append(0)
	pixel_board = board.duplicate(true)
	# them vao cac diem pixel dua data co duoc o tren
	for i in board.size():
		for j in board[i].size():
			var pixel:Sprite2D = pixel_ins.instantiate()
			$Board.add_child(pixel)
			if j == 0:
				pixel.position.x = 32
				pixel_board[i][0] = pixel
			else:
				pixel.position.x = 32 + j * 64
				pixel_board[i][j] = pixel
			pixel.get_child(0).frame = i
			pixel.get_child(1).frame = j
			#pixel.get_child(0).hide()
			#pixel.get_child(1).hide()
			pixel.position.y = 32 + i * 64
			if i < map_size and j < map_size:
				pixel.modulate = Color.WHITE
			else:
				pixel.modulate = Color.BLACK

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if (event.position.x > pixel_x[0] and event.position.x < pixel_x[1]
			and event.position.y > pixel_y[0] and event.position.y < pixel_y[1]):
				prints("event.position",event.position)
				add_marker(event.position)

func add_marker(pos):
	var x:int = (pos.x)/64
	var y:int = (pos.y)/64
	var node:Sprite2D = $Board.get_child(x+(y*board[0].size()))
	if node.modulate == Color.WHITE and board[y][x] == 0:
		board[y][x] = team_select
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
	prints("check_win",check_win())

func change_team():
	if team_select == 1:
		team_select = -1
	else:
		team_select = 1

func check_win() -> int:
	var count = 0
	var markers:Array
	for i in board.size():
		for j in board[i].size():
			if board[i][j] == team_select:
				markers.append([j,i])
	prints("markers",markers)
	
	for n in markers.size():
		var marker = markers[n]
		var x = marker[0]
		var y = marker[1]
		# Kiểm tra các hàng
		if !x in [0,map_size-1]:
			if ((board[y][x-1] == team_select and board[y][x+1] == team_select) and
			(board[y][x-2] == 0 and board[y][x+2] == 0)):
				prints("Center")
				return team_select
		elif !x in [0,1,map_size-2,map_size-1]:
			if board[y][x-1] == team_select:
				prints("Left")
				count = 0
				for i in 3:
					if board[y][x-i] == team_select:
						count += 1
						if count == 3 and board[y][x-4] == 0:
							return team_select
					else:
						count = 0
			elif board[y][x+1] == team_select:
				prints("Right")
				count = 0
				for i in 3:
					if board[y][x+i] == team_select:
						count += 1
						if count == 3 and board[y][x+4] == 0:
							return team_select
					else:
						count = 0
		# Kiểm tra các cột
		if !y in [0,map_size-1]:
			if ((board[y-1][x] == team_select and board[y+1][x] == team_select) and
			(board[y-2][x] == 0 and board[y+2][x] == 0)):
				prints("Center")
				return team_select
		elif !y in [0,1,map_size-2,map_size-1]:
			if board[y-1][x] == team_select:
				prints("Up")
				count = 0
				for i in 3:
					if board[y-i][x] == team_select and board[y-4][x] == 0:
						count += 1
						if count == 3:
							return team_select
					else:
						count = 0
			elif board[y+1][x] == team_select:
				prints("Down")
				count = 0
				for i in 3:
					if board[y+i][x] == team_select and board[y+4][x] == 0:
						count += 1
						if count == 3:
							return team_select
					else:
						count = 0
		# Kiểm tra các đường chéo
		# Các đường chéo trên
		
		# Các đường chéo dưới
	
	# Kiểm tra các hàng
	#for i in board.size():
		#count = 0
		#for j in board[i].size():
			#if board[i][j] != team_select:
				#count = 0
			#else:
				#count += 1
				#if count == 3:
					#prints("check",count,i,j)
					#return team_select
	#count = 0
	# Kiểm tra cac cột
	#for i in board[0].size():
		#count = 0
		#for j in board.size():
			#if board[j][i] != team_select:
				#count = 0
			#else:
				#count += 1
				#if count == 3:
					#prints("check",count,j,i)
					#return team_select
	#count = 0
	
	## Kiểm tra hàng và cột
	#for i in range(map_size):
		#if board[i][0] != 0 and board[i][0] == board[i][1] and board[i][0] == board[i][2]:
			#return board[i][0] # Trả về giá trị của ô thắng
		#if board[0][i] != 0 and board[0][i] == board[1][i] and board[0][i] == board[2][i]:
			#return board[0][i] # Trả về giá trị của ô thắng
	#
	## Kiểm tra đường chéo chính
	#if board[0][0] != 0 and board[0][0] == board[1][1] and board[0][0] == board[2][2]:
		#return board[0][0] # Trả về giá trị của ô thắng
	#
	## Kiểm tra đường chéo phụ
	#if board[0][2] != 0 and board[0][2] == board[1][1] and board[0][2] == board[2][0]:
		#return board[0][2] # Trả về giá trị của ô thắng
	#
	# Nếu không có ô nào thắng
	return 0

func on_game_end(team_win:int = 1):
	if team_win == 1:
		prints("O win")
	else:
		prints("X win")
