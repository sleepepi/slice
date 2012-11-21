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

### Checkboxes

If instead of a radio, the first variable were a checkbox, we may do the following:

    checkbox: daytime_emotions, options { 1: happy, 2: sad, 3: angry, 4: apathetic, 5: giddy }

    How do you feel during the day, select one or more:
      1: Happy
      2: Sad
      3: Angry
      4: Apathetic
      5: Giddy

Second Variable

    radio: get_help, options { 1: yes, 2: no }

In the branching logic for **get_help** we may do the following if the user selects at least one of Sad, Angry, or Apathetic:

    overlap(daytime_emotions, ['2', '3', '4'])

Essentially this expression states that if one of the values is selected then show the **get_help** variable.

If we wanted to only show the **get_help** variable if two or more were selected we could rewrite this to say:

    overlap(daytime_emotions, ['2', '3', '4'], 2)

The third parameter of **overlap** defines the minimum amount of choices that need to be selected. When left blank this parameter defaults to 1.

### List of expressions
More complex expressions could also be used:

    equality                      ==
    inequality                    !=
    greater than                  >
    less than                     <
    greater than or equal         >=
    less than or equal            <=
    logical OR                    ||
    logical AND                   &&
    multiple conditions           expr && (expr || expr)
    multiple choice checkboxes    overlap(variable, ['1','0'])

### Important
* Branching logic only works if the variable that needs to be conditionally hidden is located after the variable it depends on.
* Branching logic only works on variables shown on the current page of the design.
* Branching logic can also be added to sections.
