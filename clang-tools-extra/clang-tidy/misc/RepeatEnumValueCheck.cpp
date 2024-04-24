//===--- RepeatEnumValueCheck.cpp - clang-tidy ----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "RepeatEnumValueCheck.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"

using namespace clang::ast_matchers;

namespace clang::tidy::misc {

void RepeatEnumValueCheck::registerMatchers(MatchFinder *Finder) {
  // FIXME: Add matchers.
  Finder->addMatcher(enumDecl(forEach(enumConstantDecl())).bind("enum"), this);
}

void RepeatEnumValueCheck::check(const MatchFinder::MatchResult &Result) {
  const EnumDecl *Enum = Result.Nodes.getNodeAs<EnumDecl>("enum");
  // if (Enum->isScoped())
  //   return;
  std::set<int> Values;
  for (const auto *Constant : Enum->enumerators()) {
    int Value = Constant->getInitVal().getExtValue();
    if (Values.count(Value) > 0) {
      diag(Constant->getLocation(), "Duplicate value %0 in enum %1")
          << Value << Enum->getNameAsString();
    } else {
      Values.insert(Value);
    }
  }
}
} // namespace clang::tidy::misc
