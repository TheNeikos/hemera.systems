---
date: "2022-05-30T11:55:32+02:00"
---

# Prettifying the Emanote Timeline

Emanote allows you to use queries to dynamically generate static lists. For
example, all [[blog]]!

This is done with the following snippet:

    ```query {.timeline}
    path:blog/*
    ```

Internally, it then uses some emanote templates to render the timeline, which I
have adjusted to be nicer to look at:

```html
<nav class="p-4">
  <ol class="border-l-2 border-${theme}-700">
    <result>
      <li>
          <div class="flex flex-start items-center">
            <div class="bg-${theme}-700 w-4 h-4 flex items-center justify-center rounded-full -ml-2 mr-3 -mt-2"></div>
            <a class="flex-1 text-${theme}-700 font-semibold text-xl hover:underline -mt-2"
              href="${ema:note:url}">
              <ema:note:title />
            </a>
          </div>
          <ema:note:metadata>
            <div class="ml-6 mb-6 pb-6">
              <span class="text-sm"><value var="date" /></span>
            </div>
          </ema:note:metadata>
      </li>
    </result>
  </ol>
</nav>
```

And voila! The result can be seen on the [[blog]] page.
