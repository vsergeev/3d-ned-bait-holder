/********************************************************
 * Ned Bait Holder - vsergeev
 * https://github.com/vsergeev/3d-ned-bait-holder
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 11/01/2020
 *      * Initial release.
 ********************************************************/

/* [Basic] */

// in mm
slots = [10, 10, 15, 15];

// in mm
height = 65;

// in mm
depth = 10;

// in mm
wall_thickness = 1.5;

/* [Advanced] */

// in mm
drainage_diameter = 5;

// fraction from 0 to 1
slot_relative_diameter = 0.55;

// fraction from 0 to 1
slot_relative_offset = 0.15;

/* [Hidden] */

$fn = 70;

module ned_bait_holder_slot(width, height, depth, wall_thickness) {
    slot_height = height * (1 - slot_relative_offset);
    slot_diameter = slot_relative_diameter * width;

    difference() {
        /* Outside profile */
        cube([width + wall_thickness * 2, depth + wall_thickness * 2, height + wall_thickness]);
        /* Inside profile */
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([width, depth, height + wall_thickness]);
        /* Drainage hole */
        translate([(width + wall_thickness * 2) / 2, (depth + wall_thickness * 2) / 2, -wall_thickness * 2])
            cylinder(h=wall_thickness * 4, d=drainage_diameter);
        /* Slot */
        translate([(width + wall_thickness * 2) / 2, 0, wall_thickness + slot_relative_offset * height])
            union() {
                translate([-slot_diameter / 2, -wall_thickness * 2, slot_diameter / 2])
                    cube([slot_diameter, wall_thickness * 4, slot_height - slot_diameter / 3]);
                translate([0, wall_thickness * 2, slot_diameter / 2])
                    rotate([90, -90, 0])
                        cylinder(h=wall_thickness * 4, d=slot_diameter);
            }
    }
}

module ned_bait_holder(slots, height, depth, wall_thickness) {
    function cumsum(i) = (i < 0) ? 0 : slots[i] + wall_thickness + cumsum(i - 1);

    offsets = [for (i = [-1 : len(slots) - 1]) cumsum(i)];

    union() {
        for (i = [0 : len(slots) - 1]) {
            translate([offsets[i], 0, 0])
                ned_bait_holder_slot(slots[i], height, depth, wall_thickness);
        }
    }
}

ned_bait_holder(slots, height, depth, wall_thickness);
