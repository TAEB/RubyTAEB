#!/usr/bin/ruby

$safe_foods = [/\b(?:food |cram |[KC]-)rations?\b/,
               /\bgunyoki\b/, /\blembas wafers?\b/,
               /\bmelons?\b/, /\bcarrots?\b/,
               /\btins? (?:of|named) spinach\b/,
               /\boranges?\b/, /\bpears?\b/,
               /\bapples?\b/, /\bbananas?\b/,
               /\bkelp fronds?\b/, /\beucalyptus lea(?:f|ves)\b/,
               /\bcloves? of garlic\b/, /\bsprigs? of wolfsbane\b/,
               /\bslime molds?\b/, /\bcanister of RoboJuice\(tm\)/,
               /\bpancakes?\b/, /\bfortune cookies?\b/,
               /\bcandy bars?\b/, /\blumps? of royal jelly\b/,
               /\bcream pies?\b/]

