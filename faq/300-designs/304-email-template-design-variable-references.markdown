---
title: FAQ - 304 Variable References in Design Email Templates
layout: default
---

## #304 - How do I show the variable name instead of the actual variable itself in an email template?

### Referencing Sheet Header Variables

The following is a complete list of Sheet Header Variables currently available:

To enter in the subject's code:
```
    #(subject)
```
```
    S110012
```

To enter the subject's acrostic:
```
    #(subject).acrostic
```
```
    JOSM
```

To enter the site:
```
    #(site)
```
```
    Boston
```

To enter the sheet date:
```
    #(date)
```
```
    2012-11-15
```

To enter the project name:
```
    #(project)
```
```
    Clinical Trial Demo
```

To enter the user sending the sheet receipt email:
```
    #(user)
```
```
    Remo Mueller
```

To enter the user's email that is sending the sheet receipt email:
```
    #(user).email
```
```
    remosm@gmail.com
```


### Referencing Sheet Body Variables

A sheet body or design variable can be referenced in the following manner:

```
    The subject is $(age) years old.
```

Produces:

```
    The subject is 28 years old.
```

You can also reference the variable name itself:

```
    We collected the $(age).name for our subject.
```

Produces:

```
    We collected the Age at Study for our subject.
```

For variables that contain a list of options, you can also reference the option along with the captured value:

```
    This study was scored by $(scorer).
```

Produces:

```
    This study was scored by 100: John Smith.
```

If you don't want to option's value, and only the label, you can type instead:

```
    This study was scored by $(scorer).label.
```

Produces:

```
    This study was scored by John Smith.
```

Finally, if you only want the value and not the label, you can type:

```
    Scorer # $(scorer).value evaluated the test for the subject.
```

Produces:

```
    Scorer # 100 evaluated the test for the subject.
```

### Difference between Referencing Header and Body Variables

For further documentation on the difference between header and body variables, see [303 Creating Design Email Templates](faq/300-designs/303-email-template-design)
