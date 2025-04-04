using Godot;
using System;

public partial class pathdraw : Node2D
{
    private NavigationAdvisor _navbot;
    private BotNavTest _navbottest;

    public override void _Ready() {
        _navbot = FindParent("Game").FindChild("nav_test") as NavigationAdvisor;
        _navbottest = FindParent("Game").FindChild("BotNavTest") as BotNavTest;
    }

    public override void _Draw()
	{
		for (int i = 0; i < _navbot.pathArray.Length - 1; i++){

			DrawLine(_navbot.pathArray[i].Position, _navbot.pathArray[i+1].Position, new Color(0, 0, 1, 1));

		}
        for (int i = 0; i < _navbottest.pathArray.Length - 1; i++){

			DrawLine(_navbottest.pathArray[i].Position, _navbottest.pathArray[i+1].Position, new Color(1, 0, 0, 1));

		}
	}
    public override void _PhysicsProcess(double delta) {
        QueueRedraw();
    }
}




