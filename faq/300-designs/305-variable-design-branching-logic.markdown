---
title: FAQ - 305 Using Branching Logic for Variables on a Design
layout: default
---

## #305 - How do I hide certain variables on my design depending on the answer to previous questions?

After adding a variable to a design, you can specify the **branching logic** for the variable.

Let's say we have two variables on our design, and the answer to the first variable tells us whether we want to see the second variable.

First Variable:

    radio: has_children, options { 1: yes, 2: no, -9: Missing }

    Do you have children?
      1: Yes
      2: No
      Missing Codes
      -9: Missing

Second Variable:

    numeric: age_of_child

    How old is your oldest child?

In the branching logic for the **second variable** we can enter the following syntax:

    has_children == 1

