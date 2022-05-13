#!/bin/bash
import paramak
import os
rotated_circle = paramak.ExtrudeCircleShape(
points=[(1, 0),], radius=0.95, distance=1.2, workplane="XZ", name="part0.stl",)
grey_part = paramak.ExtrudeStraightShape(
points=[
	 (-1.15, -1.25),
	(1.15, -1.25),
	 (1.15, 1.75),
	(-1.15, 1.75),
	 ],
distance=1.2,
color=(0.5, 0.5, 0.5),
cut=rotated_circle,
name="grey_part",
)
red_part = paramak.RotateStraightShape(
points=[
   (0.75, -0.6),
(0.95, -0.6),
(0.95, 0.6),
(0.75, 0.6),
	],	
	 color=(0.5, 0, 0),
	 workplane="XY",
	 rotation_angle=360,
	 name="red_part",
	)
blue_part = paramak.RotateStraightShape(
	points=[
	 (0.6, -0.6),
	(0.75, -0.6),
	(0.75, 0.6),
	(0.6, 0.6),
	 ],
	 color=(0, 0, 0.5),
	 workplane="XY",
	 rotation_angle=360,
	 name="blue_part",
	)
my_reactor = paramak.Reactor([grey_part, red_part, blue_part])
my_reactor.export_dagmc_h5m(filename="dagmc.h5m", min_mesh_size=.001, max_mesh_size=.1)
