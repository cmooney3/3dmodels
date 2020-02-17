// This is a little rack that you can hang sprouting pots in.
// The specific pot dimentions in this file are currently designed to work with
// this pot:
//    https://www.thingiverse.com/thing:3449179
// Basically you can configure how many pots you want in your rack 
// and a few other qualities of the rack such as how big of risers you
// want under it to let water drip out.
// It works nicely with openscad in my experimentation.
//
// If you wanted to use a different sized pot it should be pretty easy as long
// as the pots are taper squares with rounded corners.  I've used it with a bigger
// pot I made and it worked great with them too.

$fn=50;  // Increase the smoothness for nice round curves

// Set the size of the grid (how many pots in your rack)
num_pots_x = 1;
num_pots_y = 1;

// How big of a gap between adjacent pots (the holes in the rack)
interpot_spacing_mm = 2;

// How big of an outer lip the rack has around the outerpost pots
rack_thickness_mm = 1;

// How far *below* the top lip of the pots the rack stops
rack_inset_depth_mm = 30;

// The dimensions of the cylindrical risers on the bottom of the rack 
riser_radius_mm = 15;
riser_height_mm = 16;

pot_wiggle_room_mm = 0.1;
pot_insert_wiggle_room_mm = 1.5;
drip_tray_groove_wiggle_room_mm = 1.0;

// The dimensions and characteristics of the pots
pot_wall_thickness_mm = 0.8;
pot_top_edge_mm = 76;
pot_bottom_edge_mm = 70;
pot_height_mm = 91;
pot_rounded_radius_mm = 25;
pot_drain_lip_mm = 20;
pot_drain_hole_rounded_radius_multiplier = 0.7;  // Use this to adust the curve in the drain hole


drip_tray_extra_space_around_rack_mm = 10;

// Computed dimensions of the rack -- derived from the values set above
rack_dim_x_mm = (pot_top_edge_mm + interpot_spacing_mm) * num_pots_x
                    - interpot_spacing_mm
                    + rack_thickness_mm * 2;
rack_dim_y_mm = (pot_top_edge_mm + interpot_spacing_mm) * num_pots_y
                    - interpot_spacing_mm
                    + rack_thickness_mm * 2;
rack_dim_z_mm = pot_height_mm - rack_inset_depth_mm;

module rounded_box(x_dimension_mm, y_dimension_mm, z_dimension_mm, radius_mm) {
    hull() {
        translate([radius_mm, radius_mm, 0])
            cylinder(h = z_dimension_mm,r = radius_mm);
        translate([x_dimension_mm - radius_mm, radius_mm, 0])
            cylinder(h = z_dimension_mm, r = radius_mm);
        translate([radius_mm, y_dimension_mm - radius_mm, 0])
            cylinder(h = z_dimension_mm, r = radius_mm);
        translate([x_dimension_mm-radius_mm, y_dimension_mm - radius_mm, 0])
            cylinder(h = z_dimension_mm, r = radius_mm);
    }
}

module pot(top_edge_mm, bottom_edge_mm) {
    slice_height_mm = 0.1;

    pot_inside_top_edge_mm = top_edge_mm - pot_wall_thickness_mm * 2;
    pot_inside_bottom_edge_mm = bottom_edge_mm - pot_wall_thickness_mm * 2;

    pot_bottom_edge_inset_mm = (top_edge_mm - bottom_edge_mm) / 2;
    pot_inside_bottom_edge_inset_mm = pot_bottom_edge_inset_mm + pot_wall_thickness_mm;

    drain_hole_size = bottom_edge_mm - pot_drain_lip_mm;
    drain_hole_inset_mm = (top_edge_mm - drain_hole_size) / 2;
    drain_hole_rounded_radius_mm = pot_rounded_radius_mm * pot_drain_hole_rounded_radius_multiplier;

    difference() {
        // The main pot body
        difference() {
            // The outside of the pot
            hull() {
                translate([0, 0, pot_height_mm - slice_height_mm])
                    rounded_box(top_edge_mm, top_edge_mm, slice_height_mm, pot_rounded_radius_mm);
                translate([pot_bottom_edge_inset_mm, pot_bottom_edge_inset_mm, 0])
                    rounded_box(bottom_edge_mm, bottom_edge_mm, slice_height_mm, pot_rounded_radius_mm);
            }

            // The inside of the pot
            hull() {
                translate([pot_wall_thickness_mm, pot_wall_thickness_mm, pot_height_mm - slice_height_mm])
                    rounded_box(pot_inside_top_edge_mm, pot_inside_top_edge_mm, slice_height_mm, pot_rounded_radius_mm);
                translate([pot_inside_bottom_edge_inset_mm, pot_inside_bottom_edge_inset_mm, pot_wall_thickness_mm])
                    rounded_box(pot_inside_bottom_edge_mm, pot_inside_bottom_edge_mm, slice_height_mm, pot_rounded_radius_mm);
            }
        }

        // The drain hole in the bottom
        translate([drain_hole_inset_mm, drain_hole_inset_mm, 0])
                rounded_box(drain_hole_size, drain_hole_size, pot_wall_thickness_mm, drain_hole_rounded_radius_mm);
    }
}

module pot_blank() {
    hull() {
        // The translate compensates for the added wiggle room size and keeps the resulting
        // pot centered in the same spot as the as it would've been without the wiggle room added
        translate([-pot_wiggle_room_mm / 2, -pot_wiggle_room_mm / 2, 0]) {
            pot(pot_top_edge_mm + pot_wiggle_room_mm, pot_bottom_edge_mm + pot_wiggle_room_mm);
        }
    }
}

module pot_insert() {
    pot_insert_edge_mm = pot_bottom_edge_mm - pot_wall_thickness_mm * 2 - pot_insert_wiggle_room_mm;

    drain_length_mm = pot_insert_edge_mm - pot_rounded_radius_mm * 2;
    drain_depth_mm = drain_length_mm / 3;

    insert_riser_height_mm = pot_wall_thickness_mm * 2;
    insert_riser_thickness_mm = drain_depth_mm / 2;

    // The main plate with drains cut out
    difference() {
        // The main plate that makes up the insert
        translate([-pot_insert_edge_mm / 2, -pot_insert_edge_mm / 2, -pot_wall_thickness_mm / 2])
            rounded_box(pot_insert_edge_mm, pot_insert_edge_mm, pot_wall_thickness_mm, pot_rounded_radius_mm);

        // The rectangular drains (one on each edge of the square)
        for (r = [0 : 90 : 270]) {
            rotate(r)
                translate([0, pot_insert_edge_mm / 2, 0])
                    cube([drain_length_mm, drain_depth_mm, pot_wall_thickness_mm], center = true);
        }
    }

    // Adding the risers
    translate([0, 0, insert_riser_height_mm / 2 + pot_wall_thickness_mm / 2]) {
        intersection() {
            translate([-pot_insert_edge_mm / 2, -pot_insert_edge_mm / 2, -insert_riser_height_mm / 2])
                rounded_box(pot_insert_edge_mm, pot_insert_edge_mm, insert_riser_height_mm, pot_rounded_radius_mm);
            for (r = [0 : 90 : 270]) {
                rotate(r) {
                    translate([pot_insert_edge_mm / 2, drain_length_mm / 2 + insert_riser_thickness_mm / 2, 0])
                        cube([pot_drain_lip_mm + 3, insert_riser_thickness_mm, insert_riser_height_mm], center = true);
                    translate([pot_insert_edge_mm / 2, -drain_length_mm / 2 - insert_riser_thickness_mm / 2, 0])
                        cube([pot_drain_lip_mm + 3, insert_riser_thickness_mm, insert_riser_height_mm], center = true);
                }
            }
        }
    }
}

module grid_of_pots() {
    for (x = [0 : num_pots_x - 1]) {
        for (y = [0 : num_pots_y - 1]) {
            x_offset = x * (pot_top_edge_mm + interpot_spacing_mm);
            y_offset = y * (pot_top_edge_mm + interpot_spacing_mm);
            translate([x_offset, y_offset, 0]) pot_blank();
        }
    }
}

module rack_blank() {
    translate([-rack_thickness_mm, -rack_thickness_mm, 0]) 
        rounded_box(rack_dim_x_mm, rack_dim_y_mm, rack_dim_z_mm, pot_rounded_radius_mm);
}

module rack_risers() {
    intersection() {
        for (x = [0 : num_pots_x]) {
            for (y = [0 : num_pots_y]) {
                x_offset = x * (pot_top_edge_mm + interpot_spacing_mm) - interpot_spacing_mm / 2;
                y_offset = y * (pot_top_edge_mm + interpot_spacing_mm) - interpot_spacing_mm / 2;

                translate([x_offset, y_offset, -riser_height_mm])
                    cylinder(h = riser_height_mm, r = riser_radius_mm);
            }
        }

        // Note it's scaled to stretch it comically long since we're really only trying
        // to intersect in x & y, no other reason
        translate([0, 0, -riser_height_mm]) scale([1, 1, 100]) rack_blank();
    }
}

module rack() {
    difference() {
        rack_blank();
        grid_of_pots();
    }
}

module rack_with_risers() {
    union() {
        rack();
        rack_risers();
    }
}

module drip_tray_without_groves() {
    inner_tray_dim_x_mm = rack_dim_x_mm + 2 * drip_tray_extra_space_around_rack_mm + drip_tray_groove_wiggle_room_mm;
    inner_tray_dim_y_mm = rack_dim_y_mm + 2 * drip_tray_extra_space_around_rack_mm + drip_tray_groove_wiggle_room_mm;
    inner_tray_depth_mm = riser_height_mm;

    tray_dim_x_mm = inner_tray_dim_x_mm + 2 * rack_thickness_mm;
    tray_dim_y_mm = inner_tray_dim_y_mm + 2 * rack_thickness_mm;
    tray_dim_z_mm = inner_tray_depth_mm + 2 * rack_thickness_mm;

    difference() {
        rounded_box(tray_dim_x_mm, tray_dim_y_mm, tray_dim_z_mm, pot_rounded_radius_mm);
        translate([rack_thickness_mm, rack_thickness_mm, 2 * rack_thickness_mm])
            rounded_box(inner_tray_dim_x_mm, inner_tray_dim_y_mm, inner_tray_depth_mm, pot_rounded_radius_mm);
    }
}

module drip_tray() {
    difference() {
        translate([-rack_thickness_mm - drip_tray_extra_space_around_rack_mm - drip_tray_groove_wiggle_room_mm / 2,
                   -rack_thickness_mm - drip_tray_extra_space_around_rack_mm - drip_tray_groove_wiggle_room_mm / 2,
                   -riser_height_mm - rack_thickness_mm])
            drip_tray_without_groves();

        translate([-drip_tray_groove_wiggle_room_mm / 2,
                   -drip_tray_groove_wiggle_room_mm / 2,
                   -riser_height_mm])
            rounded_box(rack_dim_x_mm + drip_tray_groove_wiggle_room_mm,
                        rack_dim_y_mm + drip_tray_groove_wiggle_room_mm,
                        rack_dim_z_mm,
                        pot_rounded_radius_mm);
    }
}


// Uncomment one of these at a time to render either the rack, the drip tray, a pot, or a pot insert
//rack_with_risers();
drip_tray();
//pot(pot_top_edge_mm, pot_bottom_edge_mm);
//pot_insert();
