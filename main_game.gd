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
			#pixel.get_child(0).frame = i
			#pixel.get_child(1).frame = j
			pixel.get_child(0).hide()
			pixel.get_child(1).hide()
			pixel.position.y = 32 + i * 64
	create_black_screen()

func create_black_screen():
	# create wall color
	# ngang
	var wall_color:Color = Color.BLACK
	for i in board[0].size():
		#for j in board.size():
		for j in [0,1,2,8,9,10]:
			pixel_board[j][i].modulate = wall_color
			
	# doc
	for i in board.size():
		#for j in board[0].size():
		for j in [0,1,2,3,4,5,11,12,13,14,15,16]:
			pixel_board[i][j].modulate = wall_color

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
		if check_win() == false:
			change_team()
		else:
			on_game_end()
		prints("board")
		prints(board)

func change_team():
	if team_select == 1:
		team_select = -1
	else:
		team_select = 1

func check_win() -> bool:
	return false

func on_game_end():
	pass
