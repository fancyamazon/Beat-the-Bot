using Godot;
using System;
using System.Collections.Generic;

public partial class NavigationAdvisor : Node2D
{

	private TileMapPathFind _pathFind2D;
	private Stack<PointInfo> _path = new Stack<PointInfo>();
	private float JumpDistanceHeightThreshold = 120.0f;
	public PointInfo[] pathArray = {};
	private PointInfo _target = null;
	private PointInfo _prevTarget = null;
	private Timer _startTime;
	private CharacterBody2D _player;
    private CharacterBody2D _bot;
	private Sprite2D my_sprite;

	public Vector2 search_point;

    private int[] movements = new int[2]; // direction, number of jumps, melee attack
	public override void _Ready()
	{
		_pathFind2D = FindParent("Game").FindChild("TileMapPathFind") as TileMapPathFind;
		_player = FindParent("Game").FindChild("Player").FindChild("Fighter") as CharacterBody2D;
        _bot = GetNode<CharacterBody2D>("Fighter");
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
		my_sprite.Position = _target.Position;
	}


	private void DoPathFinding()
	{
		var playerTilePosition = _pathFind2D.LocalToMap(search_point);
		_path = _pathFind2D.GetPlaform2DPath(_bot.GlobalPosition, _pathFind2D.MapToLocal(playerTilePosition));
		pathArray = _path.ToArray();
		
		
		GoToNextPointInPath();
	}

	public override void _PhysicsProcess(double delta)
	{
        
        movements[0] = 0;
        movements[1] = 0;
		// Handle start hunt.
		if (Input.IsActionJustPressed("ui_accept")) {
            //GD.Print("started");
			_startTime.Start();
            //GD.Print("done");
        }

		// if there is a target set
		if (_target != null)
		{
			// If the target is to the right of the current pusition
			if (_target.Position.X - 5 > _bot.GlobalPosition.X)
			{
				//direction.X = 1f;
                movements[0] = 1;
			}
			// If the target is to the left of the current pusition
			else if (_target.Position.X + 5 < _bot.GlobalPosition.X)
			{
				//direction.X = -1f;
                movements[0] = -1;
			}
			else
			{
				if (_bot.IsOnFloor())
				{
					GoToNextPointInPath();
					Jump();
				}
			}
		}
        //GD.Print(movements[0].ToString() + ", " +movements[1].ToString());

	}

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
			if (Mathf.Abs(heightDistance) <= 2)
			{
				movements[1] = 1;
			}else
			{
				movements[1] = 2;
			}
		}
	}

}
