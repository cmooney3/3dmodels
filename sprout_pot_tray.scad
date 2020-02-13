// This is a little tray that you can hang sprouting pots in.
// Designed to work with this pot:
//    https://www.thingiverse.com/thing:3449179
// Basically you can configure how many pots you want in your tray
// and a few other qualities of the tray such as how big of risers you
// want under it to let water drip out.
// It works nicely with openscad in my experimentation.

$fn=50;  // Increase the smoothness for nice round curves

// Set the size of the grid (how many pots in your tray)
num_pots_x = 2;
num_pots_y = 4;

// How big of a gap between adjacent trays
interpot_spacing_mm = 2;

// How big of an outer lip the tray has around the outerpost pots
tray_thickness_mm = 2;

// How far *below* the top lip of the pots the tray stops
tray_inset_depth_mm = 2;

// The dimensions of the cylindrical risers on the bottom of the tray
riser_radius_mm = 16;
riser_height_mm = 6;

// The dimensions and characteristics of the pots
pot_top_edge_mm = 76;
pot_bottom_edge_mm = 69;
pot_height_mm = 61;
pot_rounded_radius_mm = 25;


// Computed dimensions of the tray -- derived from the values set above
tray_dim_x_mm = (pot_top_edge_mm + interpot_spacing_mm) * num_pots_x
                    - interpot_spacing_mm
                    + tray_thickness_mm * 2;
tray_dim_y_mm = (pot_top_edge_mm + interpot_spacing_mm) * num_pots_y
                    - interpot_spacing_mm
                    + tray_thickness_mm * 2;
tray_dim_z_mm = pot_height_mm - tray_inset_depth_mm;

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

module tray_blank() {
    translate([-tray_thickness_mm, -tray_thickness_mm, 0]) 
        rounded_box(tray_dim_x_mm, tray_dim_y_mm, tray_dim_z_mm, pot_rounded_radius_mm);
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

        translate([0, 0, -riser_height_mm]) tray_blank();
    }
}

module tray_with_risers() {
    union() {
        tray();
        risers();
    }
}

module tray() {
    difference() {
        tray_blank();
        grid_of_pots();
    }
}

module drip_pan_without_riser_groves() {
    inner_pan_dim_x_mm = tray_dim_x_mm + tray_thickness_mm * 2;
    inner_pan_dim_y_mm = tray_dim_y_mm + tray_thickness_mm * 2;
    inner_pan_depth_mm = riser_height_mm;

    pan_dim_x_mm = inner_pan_dim_x_mm + 2 * tray_thickness_mm;
    pan_dim_y_mm = inner_pan_dim_y_mm + 2 * tray_thickness_mm;
    pan_dim_z_mm = inner_pan_depth_mm + 2 * tray_thickness_mm;

    difference() {
        rounded_box(pan_dim_x_mm, pan_dim_y_mm, pan_dim_z_mm, pot_rounded_radius_mm);
        translate([tray_thickness_mm, tray_thickness_mm, 2 * tray_thickness_mm])
            rounded_box(inner_pan_dim_x_mm, inner_pan_dim_y_mm, inner_pan_depth_mm, pot_rounded_radius_mm);
    }
}

module drip_pan() {
    difference() {
        translate([-3 * tray_thickness_mm, -3 * tray_thickness_mm, -riser_height_mm - tray_thickness_mm])
            drip_pan_without_riser_groves();
        tray_with_risers();
    }
}


tray_with_risers();
//drip_pan();
