using Godot;
using System;
using System.Collections;
using System.Collections.Generic;

public partial class NavigationAdvisor : Node2D
{

	private TileMapPathFind _pathFind2D;
	private Stack<PointInfo> _path = new Stack<PointInfo>();
	private float JumpDistanceHeightThreshold = 120.0f;
	public PointInfo[] pathArray = {};
	public PointInfo _target = null;
	private PointInfo _prevTarget = null;
	private Timer _startTime;
	private CharacterBody2D _player;
	private CharacterBody2D _bot;
	private Sprite2D my_sprite;

	private RayCast2D _grapple_ray;
	private Vector2 grapple_target;

	public bool grapple_for_navigation = true;

	private int last_move_direc = 0;

	public Vector2 search_point;

	private int[] movements = new int[4]; // direction, number of jumps, dash, grapple
	public override void _Ready()
	{
		_pathFind2D = FindParent("Game").FindChild("TileMapPathFind") as TileMapPathFind;
		_player = FindParent("Game").FindChild("Player").FindChild("Fighter") as CharacterBody2D;
		_bot = GetNode<CharacterBody2D>("Fighter");
		_grapple_ray = _bot.GetNode<Node2D>("GrappleController").GetNode<RayCast2D>("RayCast2D");
		my_sprite = FindParent("Game").FindChild("MySprite2") as Sprite2D;
		_startTime = GetNode<Timer>("PathFindTimer");
		search_point = Vector2.Zero;
	}

	private void OnPathFindTimerTimeout()
	{
		// if (IsOnFloor() && _player.IsOnFloor()) 	// <- This line of code
		// will ensure that the skeleton ner falls down between gaps,
		// but can introduce pauses to the skeleton if the player is in the air too much.
		// If the skeleton is on the floor
		if (_bot.IsOnFloor())
		{
			DoPathFinding();
		}
	}


	private void GoToNextPointInPath()
	{
		// If there's no points in the path
		if (_path.Count <= 0)
		{
			_prevTarget = null; // Set previous target to null
			_target = null;     // Set target to null
			return;             // Return out of the method
		}

		_prevTarget = _target;  // Set the previous target to the current target
		_target = _path.Pop();  // Set the target node to the next target in the stack
	}


	private void DoPathFinding()
	{
		var playerTilePosition = _pathFind2D.LocalToMap(search_point);
		_path = _pathFind2D.GetPlaform2DPath(_bot.GlobalPosition, _pathFind2D.MapToLocal(playerTilePosition));
		pathArray = _path.ToArray();
		
		
		GoToNextPointInPath();
	}

	public Vector2 get_target() {
		return _target.Position;
	}


	public override void _PhysicsProcess(double delta)
	{
		

		//movements[0] = 0;
		movements[1] = 0;
		movements[2] = 0;
		// Handle start hunt.
		if (Input.IsActionJustPressed("left") || 
			Input.IsActionJustPressed("right") ||
			Input.IsActionJustPressed("jump") ||
			Input.IsActionJustPressed("crouch")
			) {
			// GD.Print("started");
			_startTime.Start();
			// #GD.Print("done");
		}

		// if there is a target set
		if (_bot == null) 
		{
			GD.Print("I just found out that the bot went bleh");
			QueueFree();
		}
		if (_target != null)
		{
			if (grapple_target != null) {
				if (grapple_for_navigation) {
					grapple_target = _target.Position;
				} // override user input
				_grapple_ray.TargetPosition = grapple_target - _bot.GlobalPosition;

				if (_grapple_ray.TargetPosition.Length() >= 64) {
					if (!_grapple_ray.IsColliding() && !isEmpty(grapple_target + new Vector2(0, 32))) {
						movements[3] = 1;
					} else {

						movements[3] = 0;
					}
				} else {
					movements[3] = -1;
				}

				if (_bot.IsOnWall()) {
					movements[3] = -1;
				}
			} else {
				movements[3] = 0;
			}
			
			//preliminary grapple handling: 0 (no action) if grapple is blocked, 1 if not blocked


			// If the target is to the right of the current pusition


			if (_target.Position.X - 8> _bot.GlobalPosition.X)
			{
				movements[0] = 1;
			}
			// If the target is to the left of the current pusition
			else if (_target.Position.X  + 8< _bot.GlobalPosition.X)
			{
				//direction.X = -1f;
				movements[0] = -1;
			}

			// so we don't miss double jumps
			/*else if (_target.Position.Y > _bot.GlobalPosition.Y + 100) {
				movements[0] = 0;
			} */

			else
			{
				movements[3] = -1; // handle grappling straight up/down separately
				
				if (_bot.IsOnFloor())
				{
					GoToNextPointInPath();
					if (_target == null) return;
					Jump();
				}

				// helps fall down ledges

				// falling
				if (_target.Position.Y - _bot.GlobalPosition.Y < 32 && _target.Position.Y - _bot.GlobalPosition.Y >= 0 && _bot.Velocity.Y > 0) {

					movements[0] = 0;
				}
			}
			
			if(_target == null || _prevTarget == null) return;

			if(_target.Position.Y >= _prevTarget.Position.Y && Mathf.Abs(_target.Position.X - _prevTarget.Position.X) >= 32 * 4){
				//GD.Print("considering dash");
				if (_target.Position.X > _bot.GlobalPosition.X){
					movements[0] = 1;
					if (can_dash(1)){
						movements[2] = 1;
					} else{
						movements[2] = 0;
					}
				}
				if (_target.Position.X < _bot.GlobalPosition.X){
					movements[0] = -1;
					if (can_dash(-1)){
						movements[2] = 1;
					} else{
						movements[2] = 0;
					}
				}
			} else {
				movements[2] = 0;
			}
		
			
		} 
		//GD.Print(movements[0].ToString() + ", " +movements[1].ToString());

	}

	private bool can_dash(int direction) {
		// check for ground when you land
		if (_pathFind2D.GetCellSourceId(_pathFind2D.LocalToMap(_bot.GlobalPosition + new Vector2(32 * 8 * direction, 16))) == -1) {
			return false;
		} 
		// check for passing through
		for (int i = 1; i <= 8; i++) {
			if (_pathFind2D.GetCellSourceId(_pathFind2D.LocalToMap(_bot.GlobalPosition + new Vector2(32 * i * direction, -16))) != -1) {
				return false;
			} 
			if (_pathFind2D.GetCellSourceId(_pathFind2D.LocalToMap(_bot.GlobalPosition + new Vector2(32 * i * direction, -48))) != -1) {
				return false;
			} 
		}
		
		return true;
	}


	private Vector2 get_searchpoint_from_grapplepoint(Vector2 pos) {
		// check for ground when you land
		for (int i = 0; i < 100; i++) {
			if (isEmpty(pos)) {
				pos.Y = pos.Y + 32; // search down
			} else {
				return new Vector2(pos.X, pos.Y - 32);
			}
			
		}
		return pos;
	}

	public bool isEmpty(Vector2 pos) {
		return _pathFind2D.isCellEmpty(pos);

	}
		//Vector2[] my_arr= {new Vector2(0,0)};
		//return my_arr;//new ArrayList();
	
	public int[] get_movements() {
		return movements;
	}




	public Vector2 get_vector_to_player(){
		return _player.GlobalPosition - _bot.GlobalPosition;
	}

	private bool JumpRightEdgeToLeftEdge()
	{
		// If the previous tile was a right edge, and the target tile is a left edge
		if (_prevTarget.IsRightEdge && _target.IsLeftEdge
		&& _prevTarget.Position.Y <= _target.Position.Y // And the previous target is below the target tile
		&& _prevTarget.Position.X < _target.Position.X) // And the previous target is to the left of the target
		{
			return true;    // Return true, perform the jump
		}
		return false;       // return false, don't perform the jump
	}

	private bool JumpLeftEdgeToRightEdge()
	{
		// If the previous tile was a left edge, and the target tile is a right edge
		if (_prevTarget.IsLeftEdge && _target.IsRightEdge
		&& _prevTarget.Position.Y <= _target.Position.Y // And the previous target is below the target tile
		&& _prevTarget.Position.X > _target.Position.X) // And the previous target is to the right of the target
		{
			return true;    // Return true, perform the jump
		}
		return false;       // return false, don't perform the jump
	}
	private void Jump()
	{
		if (_prevTarget == null || _target == null || _target.IsPositionPoint)
		{
			return;
		}

		// If the previous target is above the target, and the distance is less than the jump height threshold
		if (_prevTarget.Position.Y < _target.Position.Y
		&& _prevTarget.Position.DistanceTo(_target.Position) < JumpDistanceHeightThreshold)
		{
			return;
		}

		// If the current target is above the next target and the next target is a fall tile
		if (_prevTarget.Position.Y < _target.Position.Y && _target.IsFallTile)
		{
			return; // Return, no need to jump
		}

		if (_prevTarget.Position.Y > _target.Position.Y || JumpRightEdgeToLeftEdge() || JumpLeftEdgeToRightEdge())
		{
			int heightDistance = _pathFind2D.LocalToMap(_target.Position).Y - _pathFind2D.LocalToMap(_prevTarget.Position).Y;
			if (Mathf.Abs(heightDistance) <= 3) // JumpDistanceHeightThreshold
			{
				movements[1] = 1;
			}else
			{
				movements[1] = 2;
			}
		}
	}

}
