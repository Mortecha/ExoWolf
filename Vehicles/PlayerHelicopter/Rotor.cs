using Godot;
using System;

public class Rotor : MeshInstance
{
	Vector3 axis = new Vector3(1, 0, 0);
	float rotationAmount = 0.1f;

	public override void _Process(float delta)
	{
		RotateObjectLocal(new Vector3(0, 1, 0), 0.1f);
	}
}
