/********************************************************
 * Ned Bait Holder - vsergeev
 * https://github.com/vsergeev/3d-ned-bait-holder
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.1 - 03/12/2021
 *      * Add corner radius to box.
 *  * v1.0 - 11/01/2020
 *      * Initial release.
 ********************************************************/

/* [Basic] */

// in mm
slot_widths = [10, 10, 15, 15];

// in mm
slot_height = 65;

// in mm
slot_depth = 10;

// in mm
wall_thickness = 1.5;

/* [Advanced] */

// in mm
drainage_hole_diameter = 5;

// fraction from 0 to 1
cutout_relative_diameter = 0.55;

// fraction from 0 to 1
cutout_relative_offset = 0.15;

// in mm
corner_radius = 1.5 * wall_thickness;

/* [Hidden] */

$fn = 70;

fudge_factor = 0.1;

/******************************************************************************/
/* Helper Functions */
/******************************************************************************/

function sum(v, i = 0) = (i < len(v)) ? v[i] + sum(v, i + 1) : 0;

function cumsum(v, i) = (i < 0) ? 0 : v[i] + cumsum(v, i - 1);

/******************************************************************************/
/* Derived Parameters */
/******************************************************************************/

width = sum(slot_widths) + (len(slot_widths) + 1) * wall_thickness;

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module ned_bait_profile_box() {
    offset(r=corner_radius)
        offset(delta=-corner_radius)
            square([width, slot_depth + 2 * wall_thickness], center=true);
}

module ned_bait_profile_slot(i) {
    square([slot_widths[i], slot_depth], center=true);
}

module ned_bait_profile_cutout(i) {
    cutout_width = cutout_relative_diameter * slot_widths[i];

    union() {
        translate([0, cutout_width / 2])
            circle(d = cutout_width);

        translate([-cutout_width / 2, cutout_width / 2])
            square([cutout_width, slot_height]);
    }
}

module ned_bait_profile_drainage_hole() {
    circle(d = drainage_hole_diameter);
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module ned_bait_holder() {
    slot_centers = [
        for (i = [0 : len(slot_widths) - 1])
            (-width / 2 + wall_thickness + slot_widths[i] / 2) + (wall_thickness * i + cumsum(slot_widths, i - 1))
    ];

    difference() {
        /* Base */
        linear_extrude(slot_height + wall_thickness)
            ned_bait_profile_box();

        for (i = [0 : len(slot_widths) - 1]) {
            /* Slot */
            translate([slot_centers[i], 0, wall_thickness])
                linear_extrude(slot_height + fudge_factor)
                    ned_bait_profile_slot(i);

            /* Slot Cutout */
            translate([slot_centers[i], -(slot_depth - fudge_factor) / 2, cutout_relative_offset * slot_height + wall_thickness])
                rotate([90, 0, 0])
                    linear_extrude(wall_thickness + fudge_factor)
                        ned_bait_profile_cutout(i);

            /* Drainage Hole */
            translate([slot_centers[i], 0, -fudge_factor/2])
                linear_extrude(wall_thickness + fudge_factor)
                  ned_bait_profile_drainage_hole();
        }
    }
}

ned_bait_holder();
