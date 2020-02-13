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
num_pots_x = 3;
num_pots_y = 3;

// How big of a gap between adjacent pots (the holes in the rack)
interpot_spacing_mm = 2;

// How big of an outer lip the rack has around the outerpost pots
rack_thickness_mm = 2;

// How far *below* the top lip of the pots the rack stops
rack_inset_depth_mm = 2;

// The dimensions of the cylindrical risers on the bottom of the rack 
riser_radius_mm = 8;
riser_height_mm = 6;

// The dimensions and characteristics of the pots
pot_top_edge_mm = 30;
pot_bottom_edge_mm = 20;
pot_height_mm = 40;
pot_rounded_radius_mm = 3;

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

module pot() {
    slice_height_mm = 0.1;
    pot_bottom_edge_inset_mm = (pot_top_edge_mm - pot_bottom_edge_mm) / 2;    
    hull() {
        translate([0, 0, pot_height_mm - slice_height_mm]) 
            rounded_box(pot_top_edge_mm, pot_top_edge_mm, slice_height_mm, pot_rounded_radius_mm);
        translate([pot_bottom_edge_inset_mm, pot_bottom_edge_inset_mm, 0]) 
            rounded_box(pot_bottom_edge_mm, pot_bottom_edge_mm, slice_height_mm, pot_rounded_radius_mm);
    }
}

module grid_of_pots() {
    for (x = [0 : num_pots_x - 1]) {
        for (y = [0 : num_pots_y - 1]) {
            x_offset = x * (pot_top_edge_mm + interpot_spacing_mm);
            y_offset = y * (pot_top_edge_mm + interpot_spacing_mm);
            translate([x_offset, y_offset, 0]) pot();
        }
    }
}

module rack_blank() {
    translate([-rack_thickness_mm, -rack_thickness_mm, 0]) 
        rounded_box(rack_dim_x_mm, rack_dim_y_mm, rack_dim_z_mm, pot_rounded_radius_mm);
}

module risers() {
    intersection() {
        for (x = [0 : num_pots_x]) {
            for (y = [0 : num_pots_y]) {
                x_offset = x * (pot_top_edge_mm + interpot_spacing_mm) - interpot_spacing_mm / 2;
                y_offset = y * (pot_top_edge_mm + interpot_spacing_mm) - interpot_spacing_mm / 2;

                translate([x_offset, y_offset, -riser_height_mm])
                    cylinder(h = riser_height_mm, r = riser_radius_mm);
            }
        }

        translate([0, 0, -riser_height_mm]) rack_blank();
    }
}

module rack_with_risers() {
    union() {
        rack();
        risers();
    }
}

module rack() {
    difference() {
        rack_blank();
        grid_of_pots();
    }
}

module drip_tray_without_riser_groves() {
    inner_tray_dim_x_mm = rack_dim_x_mm + rack_thickness_mm * 2;
    inner_tray_dim_y_mm = rack_dim_y_mm + rack_thickness_mm * 2;
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
        translate([-3 * rack_thickness_mm, -3 * rack_thickness_mm, -riser_height_mm - rack_thickness_mm])
            drip_tray_without_riser_groves();
        rack_with_risers();
    }
}


// Uncomment one of these at a time to render either the rack or the drip tray
rack_with_risers();
//drip_tray();
