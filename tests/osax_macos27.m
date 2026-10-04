#import <Foundation/Foundation.h>
#include <assert.h>
#include "../src/osax/arm64_payload.m"

int main(void)
{
    NSOperatingSystemVersion golden_gate = { 27, 0, 0 };
    NSOperatingSystemVersion unverified = { 27, 1, 0 };
    NSOperatingSystemVersion changed_abi = { 27, 2, 0 };

    assert(get_dppm_pattern(golden_gate));
    assert(get_move_space_pattern(golden_gate));
    assert(get_set_front_window_pattern(golden_gate));
    assert(get_dppm_offset(golden_gate) == 0x40000);
    assert(get_move_space_offset(golden_gate) == 0x170000);
    assert(get_set_front_window_offset(golden_gate) == 0x10000);

    // Unverified versions must not pick up the 27.0 private calling conventions.
    assert(!get_dppm_pattern(unverified));
    assert(!get_move_space_pattern(unverified));
    assert(!get_set_front_window_pattern(unverified));
    assert(!get_dppm_pattern(changed_abi));
    assert(!get_move_space_pattern(changed_abi));
    assert(!get_set_front_window_pattern(changed_abi));

    puts("macOS 27.0 patterns enabled; unverified 27.x versions remain disabled");
    return 0;
}
