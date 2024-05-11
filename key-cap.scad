module KeyCap() {
	$fn=128;
	cap_width = 20;
	r = 27; // radius of cap top
	cap_r_h = cap_width + (r^2 - (cap_width/2)^2)^(1/2);
	thickness = 1.5;
	cornar_radius = 7;

	module CapR(radius)
		rotate([-90, 0, 0])
		color("red")
		linear_extrude(cap_width)
		circle(radius);

	module CornarsMask(radius) {
		module CornarMask() {
			difference() {
				square(radius);
				translate([radius, radius, 0]) circle(radius);
			}
		}
		translate([0, 0, cap_width]){
			CornarMask();
			translate([cap_width, 0, 0]) mirror([1, 0, 0]) CornarMask();
			translate([0, cap_width, 0]) mirror([0, 1, 0]) {
				CornarMask();
				translate([cap_width, 0, 0]) mirror([1, 0, 0]) CornarMask();
			}
		}
	}

	module Block()
		difference() {	
			linear_extrude(cap_width)
				difference() {
					square(cap_width);
					CornarsMask(cornar_radius);
				}
			translate([cap_width/2, 0, cap_r_h])
				CapR(r);
		}

	difference() {
		Block();
		translate([0, 0, -thickness]) Block();
	}
}

module KeyCap2() {
	cap_width = 20;
	cap_height = cap_width;

	layers = 128;
	layer_thickness = cap_height / layers;
	wall_line_width = 1;
	min_angle = 20;
	max_angle = 90;
	min_r = 20;
	max_r = 40;

	function capPosZ(x) = 3 * -16^(x-2) + 1; // 0 <= x <= 2

	module Arc2(radius) {
		angle = 2 * asin(cap_width / (2 * radius));

		translate([0, 0, 0])
			rotate([0, 90, 0])
			translate([-radius, 0, 0])
			rotate([0, 0, -angle/2])
			rotate_extrude(angle = angle, $fn=64)
			translate([radius, 0, 0])
			square([wall_line_width, layer_thickness]);
	}

	module SquareCap(radius) {
		for (i = [0 : layers/2]) {
			x = 2 / (layers / 2) * i; // [0, 2]
			translate([layer_thickness * i, 0, capPosZ(x)]) Arc2(radius);
		}
		mirror([1, 0, 0])
			for (i = [0 : layers/2]) {
				x = 2 / (layers / 2) * i; // [0, 2]
				translate([layer_thickness * i, 0, capPosZ(x)]) Arc2(radius);
			}
	}

	intersection() {
		SquareCap(20);
		translate([0, 0, -5]) linear_extrude(20) circle(d=cap_width, true);
	}
}

KeyCap2();
