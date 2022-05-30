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
