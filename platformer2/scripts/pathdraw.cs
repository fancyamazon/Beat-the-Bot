using Godot;
using System;

public partial class pathdraw : Node2D
{
    private NavigationAdvisor _navbottest;

    [Export]
    private Color myColor = new Color(1,0,0,1);

    public override void _Ready() {
        //_navbot = FindParent("Game").FindChild("nav_test") as NavigationAdvisor;
        _navbottest = GetParent() as NavigationAdvisor;
        
    }

    public override void _Draw()
	{
		/*for (int i = 0; i < _navbot.pathArray.Length - 1; i++){

			DrawLine(_navbot.pathArray[i].Position, _navbot.pathArray[i+1].Position, new Color(0, 0, 1, 1));

		}*/
        
        for (int i = 0; i < _navbottest.pathArray.Length - 1; i++){

			DrawLine(_navbottest.pathArray[i].Position - _navbottest.Position, _navbottest.pathArray[i+1].Position - _navbottest.Position, myColor);

		}
		DrawLine(_navbottest.search_point - _navbottest.Position - new Vector2(30,-30), _navbottest.search_point - _navbottest.Position + new Vector2(30,-30), myColor);
		DrawLine(_navbottest.search_point - _navbottest.Position - new Vector2(30,30), _navbottest.search_point - _navbottest.Position + new Vector2(30,30), myColor);
	}
    public override void _PhysicsProcess(double delta) {
        QueueRedraw();
    }
}




