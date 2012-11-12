---
title: FAQ - #303 Creating Design Email Templates
layout: default
---

## #303 - Why aren't my variables showing up correctly in my design email templates?

Email templates reference two types of variables. The variables that are stored in the sheet header, (ex: subject, site, project, date), and the variables that are captured on the design itself.

The sheet header variables always use the <b>#</b> hash or number symbol. For example:

```
    #(subject)
```

The sheet body variables always use the <b>$</b> dollar symbol. For example:

```
  $(age)
```

<hr class="soften">
