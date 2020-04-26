// This file generates four different pieces that all work together to make a pot rock.
// The four parts are:
// 1. Pot -- This part is pretty obvious, it's the body of one of the pots that sit inside the rack.
// 2. Pot Insert -- This is a little piece that sits in the bottom of the pot, to allow the water to drain out.  You need one insert per pot.
// 3. Rack -- This part contains a grid of holes that the pots fit in.  It holds them nicely and lifts them up off the ground so they can drain.
// 4. Drip Tray -- This part is a tray that sits under the rack to catch drips.
//
// How to use:
// 1. Configure your pot dimensions by setting the global variables below.
// 2. Generate each of the four pieces in turn, by getting one of the four `generate_*` variables to `1` and the others all to `0`
// 3. Print them all separately and put them all together.  (You'll probably need several copies of the pot/insert to fill all the slots in your rack)
//
// Obviously there are a lot of different dimensions you can play with here, so if you're tinkering around it's pretty easy to make a mistake.
// You may find it a good exercise to do it step by step in this order:
// 1. Print a pot & insert and make sure they fit together and the size/shape you want.
// 2. Next, tweak the parameters for the rack.  But -- print a 1x1 rack (and corresponding drip tray) instead of whatever size you really want.  This lets you make sure it looks right and that the pot fits in perfectly, before going forward.
// 3. Once your little mini-rack looks good to you, go ahead and do it full-size.


// Increase the smoothness for nice round curves
$fn=50;

// Set to true to generate the pot rack
generate_rack = 1;
// Set to true to generate the drip tray
generate_drip_tray = 0;
// Set to true to generate the body of a pot
generate_pot = 0;
// Set to true to generate the inert that sits at the bottom of a pot
generate_pot_insert = 0;

// How many pots in the grid of your rack (X direction)
num_pots_x = 3;
// How many pots in the grid of your rack (Y direction)
num_pots_y = 2;

// How big of a gap between adjacent pots in the rack
interpot_spacing_mm = 2;

// How big of an outer lip the rack has around the outerpost pots
rack_thickness_mm = 1;

// How far *below* the top lip of the pots the rack stops
rack_inset_depth_mm = 30;

// The radius of the cylindrical risers on the bottom of the rack 
riser_radius_mm = 15;
// The height of the cylindrical risers on the bottom of the rack 
riser_height_mm = 16;

// A little extra wiggle room added around the pots in the rack to accomodate error, this number worked on my machine.  If the pots sit "too high" or "too low" in your rack, this is the value you want to adjust
pot_wiggle_room_mm = 0.1;
// A little wiggle room around the insert at the bottom of the pot.  It's not super important to be precise
pot_insert_wiggle_room_mm = 1.5;
// A little wiggle room around the groove in the drip tray around the risers that sit in it. Also doesn't need to be precise
drip_tray_groove_wiggle_room_mm = 1.0;

// The wall thickness of an individual pot
pot_wall_thickness_mm = 0.8;
// The size of the square that makes up the "top" of the pot
pot_top_edge_mm = 76;
// The size of the square that makes up the "bottom" of the pot
pot_bottom_edge_mm = 70;
// How tall the pots should be
pot_height_mm = 91;
// The radius of how rounded-off the corners of the pots are
pot_rounded_radius_mm = 25;
// How big the lip at the bottom of a pot is (that the insert sits on and water drains through)
pot_drain_lip_mm = 20;
// A multiplier to adjust the round-ness of the drain hole at the bottom of the pot (mostly cosmetic)
pot_drain_hole_rounded_radius_multiplier = 0.7;


// How far the drip tray sticks out around the rack.
drip_tray_extra_space_around_rack_mm = 10;

// Computed dimensions of the rack -- derived from the values set above, you shouldn't need to modify these.
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

// This actually generates the various parts of the pot.  You can turn them on/off with global variables at the top of the file.
if (generate_rack) { rack_with_risers(); }
if (generate_drip_tray) { drip_tray(); }
if (generate_pot) { pot(pot_top_edge_mm, pot_bottom_edge_mm); }
if (generate_pot_insert) { pot_insert(); }
