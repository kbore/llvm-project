// RUN: %check_clang_tidy %s misc-repeat-enum-value %t

// FIXME: Add something that triggers the check here.
enum test_repeat_enum {
    TEST_ENUM_0,
    TEST_ENUM_1,
    TEST_ENUM_2 = 1,
    TEST_ENUM_3,
    TEST_ENUM_4 = TEST_ENUM_3,
};
// CHECK-MESSAGES: :[[@LINE-1]]:6: warning: function 'f' is insufficiently awesome [misc-repeat-enum-value]

// FIXME: Verify the applied fix.
//   * Make the CHECK patterns specific enough and try to make verified lines
//     unique to avoid incorrect matches.
//   * Use {{}} for regular expressions.
// CHECK-FIXES: {{^}}void awesome_f();{{$}}

// FIXME: Add something that doesn't trigger the check here.
enum test_repeat_enum_nolint {
    TEST_ENUM_NO_LINT_0,
    TEST_ENUM_NO_LINT_1,
    TEST_ENUM_NO_LINT_2 = 1,    //NOLINT(misc-repeat-enum-value)
    TEST_ENUM_NO_LINT_3,
    TEST_ENUM_NO_LINT_4,
};
