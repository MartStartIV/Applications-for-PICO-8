<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PICO-8 Applications Repository</title>
    <!-- Links to the styles file from Part 1 -->
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <header>
        <h1>PICO-8 Ecosystem Applications</h1>
        <p>In this repository, I will be posting the applications I develop specifically for this platform. To ensure these applications work, it is recommended that you have the <code>picante8_libretro.so</code> core installed within your TreeFrogUI system.</p>
        
        <div class="system-notice">
            <strong>Supported Systems:</strong> This core is actively supported on platforms running emulation frontends and custom firmwares such as <strong>muOS</strong> (RG35XX series), <strong>ArkOS</strong>, and compatible RetroArch handheld environments utilizing TreeFrogUI.
        </div>
    </header>

    <main>
        <h2>Featured Applications</h2>

        <!-- START OF AN APP CARD -->
        <div class="app-card">
            <div class="app-header">
                <h3>Calculator Xtree</h3>
                <span class="app-version">V0.01</span>
            </div>
            
            <div class="app-body">
                <p>
                    <strong>Calculator Xtree</strong> is a hybrid utility engineered for PICO-8. This initial release features core support for standard basic mathematical functions, seamlessly combined with an advanced scientific mode that can be toggled on demand. It features a fully dynamic rendering engine capable of redrawing the custom user interface instantly to support multiple high-fidelity color presets.
                </p>

                <!-- Image gallery (Replace 'src' with your real GitHub image paths later) -->
                <div class="app-gallery">
                    <img src="screenshot1.png" alt="Calculator Xtree Standard Mode">
                    <img src="screenshot2.png" alt="Calculator Xtree Scientific Mode">
                    <img src="screenshot3.png" alt="Calculator Xtree Cyberpunk Theme">
                </div>

                <!-- Shortcuts and additional functions section -->
                <div class="shortcuts-section">
                    <h4>Additional Functions & Key Shortcuts</h4>
                    <ul class="shortcuts-list">
                        <li><strong>B + Up Arrow:</strong> Toggles between Standard Mode and Advanced Scientific Mode. The on-screen indicator dynamically updates (<code>MODE: STANDARD / MODE: SCIENTIFIC</code>).</li>
                        <li><strong>B + Right Arrow:</strong> Switches immediately between 5 high-fidelity Cyberpunk color themes, redrawing the entire user interface instantly.</li>
                        <li><strong>B + Left Arrow:</strong> Triggers the cinematic "About" screen, initiating an automated scrolling display containing development notes, specifications, and app versioning.</li>
                        <li><strong>A + Right Arrow:</strong> Performs a Quick Clear All. Instantly clears the primary display (0), wipes the sub-display operation history, and resets internal variables for a safe restart.</li>
                    </ul>
                </div>

                <!-- Version history dropdown -->
                <details class="changelog-dropdown">
                    <summary>Version History & Changelog</summary>
                    <div class="changelog-content">
                        
                        <!-- Version Block (Add new ones on top when updating) -->
                        <div class="version-block">
                            <h5>Version 0.01 (Initial Release)</h5>
                            <ul>
                                <li>Initial software launch.</li>
                                <li>Implemented core support for standard calculations blended with optional scientific mode features.</li>
                                <li>Integrated native compatibility for advanced scientific workflows.</li>
                                <li>Added support for on-the-fly custom theme switching using quick access hotkeys.</li>
                            </ul>
                        </div>
                        
                    </div>
                </details>
            </div>
        </div>
        <!-- END OF AN APP CARD -->

    </main>

    <footer>
        <p>Developed for PICO-8 & Picante8 Ecosystem | View on GitHub</p>
    </footer>

</body>
</html>
