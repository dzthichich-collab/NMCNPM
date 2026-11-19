(() => {
    const path = window.location.pathname.toLowerCase();
    const homePaths = ["/", "/home", "/home/index", "/account/login", "/account/register"];
    if (homePaths.includes(path)) return;

    // Add one guard entry so Chrome's Back button returns to the app home page.
    window.history.pushState({ backToHome: true }, "", window.location.href);
    window.addEventListener("popstate", () => {
        window.location.replace("/Home/Index");
    });
})();
