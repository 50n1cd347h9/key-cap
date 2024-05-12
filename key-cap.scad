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

module CapCurve() {
	cap_h = cap_w;

	capPosZ = function (x, y) -16^(y/4.2 - 2) + 1/5 * (x/3.3)^2 + 1;
	
	Plot3D([-cap_w/2, cap_w/2], [0, cap_w/2], capPosZ, thickness=1.5);
	mirror([0, 1, 0])
	Plot3D([-cap_w/2, cap_w/2], [0, cap_w/2], capPosZ, thickness=1.5);
}

cap_w = 20;
CapCurve();
