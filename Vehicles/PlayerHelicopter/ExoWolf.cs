using Godot;
using System;

public class ExoWolf : RigidBody
{
	// Declare member variables here. Examples:
	//private float throttle = 1.0f;
	// private string b = "text";

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//Input.SetMouseMode(Input.MouseModeEnum.Captured);


	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(float delta)
	{
		// if (Input.IsActionPressed("w"))
		// {
		// 	GD.Print("W Pressed");
		// }
	}
}
