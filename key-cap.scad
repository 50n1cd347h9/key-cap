cap_w = 17;

module Plot3D(x_range, y_range, z_func, granularity=20, thickness=1) {
	function reverse(x) = [for(i = [len(x)-1 : -1 : 0]) x[i]];
	dx = (x_range[1] - x_range[0]) / granularity;
	dy = (y_range[1] - y_range[0]) / granularity;
	faces = [
		[0, 1, 2],
		[3, 4, 5],
		[0, 3, 4, 1],
		[1, 4, 5, 2],
		[2, 5, 3, 0]
	];

	points = [
		for(y = [y_range[0]: dy : y_range[1]])
			[
				for(x = [x_range[0] : dx: x_range[1]])
					[x, y, z_func(x, y)]	
			]
	];

	for(yi = [0:len(points) - 2]) {
		for(xi = [0:len(points) - 2]) {
			p0 = points[yi][xi];
			p1 = points[yi][xi + 1];
			p2 = points[yi + 1][xi];
			p3 = points[yi + 1][xi + 1];

			t1_top = [p0, p1, p3];
			t1_bottom = t1_top - [[0, 0, thickness],
			[0, 0, thickness], 
			[0, 0, thickness]];
			hull() polyhedron(points=concat(t1_top, t1_bottom),
					faces=faces);

			t2_top = [p0, p2, p3];
			t2_bottom = t2_top - [[0, 0, thickness],
			[0, 0, thickness], 
			[0, 0, thickness]];
			hull() polyhedron(points=concat(t2_top, t2_bottom),
					faces=faces);
		}
	}
}

module CapSurface() {
	cap_h = cap_w;

	capPosZ = function (x, y) -18^(y/3.7 - 2) + 1/5 * (x/3.3)^2 + 1;
	
	Plot3D([-cap_w/2, cap_w/2], [0, cap_w/2], capPosZ, thickness=1.5);
	mirror([0, 1, 0])
	Plot3D([-cap_w/2, cap_w/2], [0, cap_w/2], capPosZ, thickness=1.5);
}

module CapMask(radius=5) {
	for(i = [1, 2, 3, 4])
	rotate([0, 0, 90 * i])
	difference() {
		translate([cap_w/2 - radius/2, cap_w/2 - radius/2, 0]) 
		square(radius, true);
		color("red")
		translate([cap_w/2 - radius, cap_w/2 - radius, 0]) 
		circle(radius, $fn=64);
	}
}

module StemMount() {
	height = 3.8;
	diameter=5.5;
	inner_width = 1.17;
	inner_depth = 4.6;
	inner_radius = 0.3;
	inner_circle_pos = [inner_width/2+inner_radius, inner_width/2+inner_radius, 0];
	inner_square_pos = inner_circle_pos - [inner_radius, inner_radius, 0];
	inner_arc_pos = [];
	inner_wall_thickness = 0.4;

	module Cross() {
		union() {
			square([inner_width, inner_depth], true);
			rotate([0, 0, 90])
				square([inner_width, inner_depth], true);
		}
	}

	module InnerCircle() {
		color("orange")
		circle(r=inner_radius, $fn=32);	
	}

	module InnerSquare() {
			color("cyan")
			square(inner_radius);
	} 

	module InnerArc() {
		r = inner_depth/2;
		cornar_r = 0.2;

		module CornarMask() {
		}

		module Mask() {
			width = inner_width/2+inner_wall_thickness;
			color("aqua") {
				square([r, width]);
				translate([width, 0, 0])
					rotate([0, 0, 90])
						square([r, width]);
				difference() {
					square(2*r, center=true);
					square(r);
				}
			}
		}

		color("lime") 
		difference() {
			circle(r, $fn=32);
			Mask();
		}
	}
	
	module PlaceFourLoc(pos=[0, 0]) {
		translate(pos)
		children();
		mirror([1, 0, 0])
		translate(pos)
		children();
		mirror([0, 1, 0]) {
			translate(pos)
			children();
			mirror([1, 0, 0])
			translate(pos)
			children();
		}
	}
	
	linear_extrude(height)
	difference() {
		circle(d=diameter, $fn=32);
		union() {
			Cross();
			union() {
				difference() {
					PlaceFourLoc(inner_square_pos) InnerSquare();
					PlaceFourLoc(inner_circle_pos) InnerCircle();
				}
				PlaceFourLoc() InnerArc();
				translate([-inner_width/2, 0, 0])
					square([inner_width, inner_depth], false);
			}
		}
	}
}

//CapSurface();

StemMount();
translate([0, 0, 4.2])
	difference() {
		import("cap-surface.stl");
		linear_extrude(10, center=true) CapMask(7);
	}
