(function() {
    'use strict';
    
    document.addEventListener('contextmenu', e => e.preventDefault());
    
    document.addEventListener('keydown', e => {
        if (e.key === 'F12' || (e.ctrlKey && e.shiftKey && e.key === 'I') || 
            (e.ctrlKey && e.shiftKey && e.key === 'J') || (e.ctrlKey && e.key === 'U')) {
            e.preventDefault();
        }
    });
    
    document.addEventListener('copy', e => {
        if (!e.target.closest('#modalCode')) {
            e.preventDefault();
        }
    });
})();

const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');
const modal = document.getElementById('scriptModal');
const keyAuthModal = document.getElementById('keyAuthModal');

if (!hamburger || !navMenu || !modal || !keyAuthModal) {
    console.error('Required elements not found');
}

let isAuthenticated = false;
let sessionKey = ''; // Guardará temporalmente la llave

// Rate limiter: max 5 intentos por 10 minutos
const AUTH_MAX_ATTEMPTS = 5;
const AUTH_WINDOW_MS = 10 * 60 * 1000; // 10 minutos
let authAttempts = [];

function isRateLimited() {
    const now = Date.now();
    authAttempts = authAttempts.filter(t => now - t < AUTH_WINDOW_MS);
    return authAttempts.length >= AUTH_MAX_ATTEMPTS;
}

function recordAuthAttempt() {
    authAttempts.push(Date.now());
}

if (hamburger && navMenu) {
    const toggleMenu = () => navMenu.classList.toggle('active');
    hamburger.addEventListener('click', toggleMenu);
    hamburger.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            toggleMenu();
        }
    });
}

if (navMenu) {
    document.querySelectorAll('.nav-menu a').forEach(link => {
        link.addEventListener('click', () => {
            navMenu.classList.remove('active');
        });
    });
}

const scripts = {
    animeLimitless: {
        title: 'ANIME LIMITLESS',
        isPremium: true
    },
    elPaso: {
        title: 'EL PASO, TEXAS: BORDER ROLEPLAY',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://tiny-bird-d5da.saraescobar0806.workers.dev/"))()`
    },
    sailorPiece: {
        title: 'SAILOR PIECE — Ghoul Update',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://sailor-hub.saraescobar0806.workers.dev/"))()`
    },
    swingObby: {
        title: 'SWING OBBY FOR BRAINROTS',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/Jairoxdhola/main/refs/heads/main/main.lua"))()`
    },
    murderersVsSheriffs: {
        title: 'MURDERERS VS SHERIFFS — Duels',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/Jairoxdhola/aim-assits/refs/heads/main/main.lua"))()`
    },
    escapeObbies: {
        title: 'ESCAPE OBBIES FOR BRAINROTS',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/saraescoba0809-creator/main.lua/refs/heads/main/main.lua"))()`
    },
    escapeTsunami: {
        title: 'ESCAPE TSUNAMI FOR BRAINROTS',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://gist.githubusercontent.com/saraescoba0809-creator/a7f35ea6414c860969cc397ee0515195/raw/f388544f4eb322264163079b5b4a404aa73a98e4/main.lua"))()`
    },
    saveBrainrots: {
        title: 'SAVE BRAINROTS FROM LAVA',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://gist.githubusercontent.com/saraescoba0809-creator/f725219612f49f010a342ae3d4b2f6cb/raw/main.lua"))()`
    },
    surviveHomelander: {
        title: 'Survive Homelander',
        isPremium: true
    },
    animeLimitlessAuto: {
        title: 'ANIME LIMITLESS — Auto Collect Soul',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://autocollectsoulandserverop.saraescobar0806.workers.dev/?nocache=" .. tostring(os.time()), true))()`
    },
    basketballLegends: {
        title: 'BASKETBALL LEGENDS',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://basketball-legends.saraescobar0806.workers.dev/"))()`
    },
    outrunASpeedster: {
        title: 'OUTRUN A SPEEDSTER',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlnxcygod-spec/outrun-a-speedster/refs/heads/main/sx"))()`
    },
    powerSimulatorX: {
        title: 'POWER SIMULATOR X',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlnxcygod-spec/psx/refs/heads/main/sx"))()`
    },
    trackRace: {
        title: 'TRACK RACE',
        isPremium: false,
        code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlnxcygod-spec/racetrack/refs/heads/main/s"))()`
    }
};

async function viewScript(type) {
    const script = scripts[type];
    if (!script) return;

    if (script.isPremium) {
        if (!isAuthenticated) {
            keyAuthModal.style.display = 'block';
            keyAuthModal.dataset.pendingScript = type;
            return;
        }
        
        const modalTitle = document.getElementById('modalTitle');
        const modalCode = document.getElementById('modalCode');
        const keyRequirement = document.getElementById('keyRequirement');
        
        modalTitle.textContent = "Loading...";
        modalCode.textContent = "Fetching secure script from server...";
        keyRequirement.innerHTML = '';
        modal.style.display = 'block';
        
        try {
            const response = await fetch(`https://nexus-seguridad.saraescobar0806.workers.dev/?id=${type}`, {
                headers: { 'Authorization': sessionKey }
            });
            
            if (response.ok) {
                const data = await response.json();
                script.code = data.code;
                script.key = data.key;
                showPremiumModal(script);
            } else {
                modalCode.textContent = "Error: Access denied or session expired.";
                isAuthenticated = false; // Reset auth
            }
        } catch(e) {
            modalCode.textContent = "Error connecting to security server.";
        }
        return;
    }
    
    // Free scripts flow
    const modalTitle = document.getElementById('modalTitle');
    const modalCode = document.getElementById('modalCode');
    const keyRequirement = document.getElementById('keyRequirement');
    
    modalTitle.textContent = script.title;
    modalCode.textContent = script.code;
    
    keyRequirement.innerHTML = `
        <div class="free-notice">
            <i class="fas fa-check"></i>
            <p><strong>Keyless Script — Ready to Use</strong></p>
        </div>
    `;
    
    modal.style.display = 'block';
}

function showPremiumModal(script) {
    const modalTitle = document.getElementById('modalTitle');
    const modalCode = document.getElementById('modalCode');
    const keyRequirement = document.getElementById('keyRequirement');
    
    modalTitle.textContent = script.title;
    modalCode.textContent = script.code;
    
    keyRequirement.innerHTML = `
        <div class="premium-notice">
            <i class="fas fa-key"></i>
            <p><strong>Premium Script — Key Required</strong></p>
            <p class="key-display"><i class="fas fa-lock-open"></i> Key: <code>${script.key}</code></p>
            <p class="discord-reminder">
                Access granted. Use this key in the script menu.
            </p>
        </div>
    `;
}

function copyCode() {
    const code = document.getElementById('modalCode').textContent;
    navigator.clipboard.writeText(code).then(() => {
        showCopySuccess('Script copied to clipboard');
    }).catch(err => {
        showCopySuccess('Failed to copy. Please try manual copy.', true);
    });
}

function copyToClipboard() {
    const code = document.getElementById('modalCode').textContent;
    
    const textarea = document.createElement('textarea');
    textarea.value = code;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    
    try {
        document.execCommand('copy');
        showCopySuccess('Script copied');
    } catch (err) {
        showCopySuccess('Please copy manually', true);
    }
    
    document.body.removeChild(textarea);
}

function showCopySuccess(message, isError = false) {
    const successDiv = document.getElementById('copySuccess');
    successDiv.textContent = message;
    successDiv.className = isError ? 'copy-success error' : 'copy-success';
    successDiv.style.display = 'block';
    
    setTimeout(() => {
        successDiv.style.display = 'none';
    }, 3000);
}

document.querySelectorAll('.close').forEach(closeBtn => {
    closeBtn.addEventListener('click', function() {
        this.closest('.modal').style.display = 'none';
    });
});

window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
    if (e.target === keyAuthModal) {
        keyAuthModal.style.display = 'none';
    }
});

const keyAuthForm = document.getElementById('keyAuthForm');
if (keyAuthForm) {
    keyAuthForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const inputKey = document.getElementById('masterKey').value;
        const errorDiv = document.getElementById('keyAuthError');
        const submitBtn = e.target.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        
        if (isRateLimited()) {
            const mins = Math.ceil(AUTH_WINDOW_MS / 60000);
            errorDiv.textContent = `Demasiados intentos. Espera ${mins} minutos antes de volver a intentarlo.`;
            errorDiv.style.display = 'block';
            setTimeout(() => { errorDiv.style.display = 'none'; }, 5000);
            return;
        }

        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Verifying...';
        
        try {
            const pendingScript = keyAuthModal.dataset.pendingScript;
            recordAuthAttempt();
            
            const response = await fetch(`https://nexus-seguridad.saraescobar0806.workers.dev/?id=${pendingScript}`, {
                headers: { 'Authorization': inputKey }
            });
            
            if (response.ok) {
                const data = await response.json();
                
                sessionKey = inputKey;
                isAuthenticated = true;
                errorDiv.style.display = 'none';
                keyAuthModal.style.display = 'none';
                document.getElementById('masterKey').value = '';
                
                const script = scripts[pendingScript];
                script.code = data.code;
                script.key = data.key;
                
                showPremiumModal(script);
                modal.style.display = 'block';
                
                delete keyAuthModal.dataset.pendingScript;
                showCopySuccess('Access granted. Connected securely.', false);
            } else {
                errorDiv.textContent = 'Invalid key! Please enter the correct master key.';
                errorDiv.style.display = 'block';
                setTimeout(() => { errorDiv.style.display = 'none'; }, 3000);
            }
        } catch(e) {
            errorDiv.textContent = 'Connection error. The security server is not responding.';
            errorDiv.style.display = 'block';
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    });
}

function closeKeyAuth() {
    if (keyAuthModal) {
        keyAuthModal.style.display = 'none';
        delete keyAuthModal.dataset.pendingScript;
    }
}

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        if (window.scrollY > 50) {
            navbar.style.background = 'rgba(10, 10, 15, 0.95)';
        } else {
            navbar.style.background = 'rgba(10, 10, 15, 0.85)';
        }
    }
});

