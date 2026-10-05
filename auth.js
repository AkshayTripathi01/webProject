// Register Form
const registerForm = document.getElementById('registerForm');
if (registerForm) {
    registerForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const msgDiv = document.getElementById('registerMessage');
        
        const name = document.getElementById('regName').value;
        const email = document.getElementById('regEmail').value;
        const phone = document.getElementById('regPhone').value;
        const password = document.getElementById('regPassword').value;
        
        try {
            const response = await fetch(`${API_URL}/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, email, password, phone })
            });
            
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message);
            }
            
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            
            msgDiv.className = 'message success';
            msgDiv.textContent = 'Registration successful! Redirecting...';
            
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 1500);
        } catch (err) {
            msgDiv.className = 'message error';
            msgDiv.textContent = err.message;
        }
    });
}

// Login Form
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const msgDiv = document.getElementById('loginMessage');
        
        const email = document.getElementById('loginEmail').value;
        const password = document.getElementById('loginPassword').value;
        
        try {
            const response = await fetch(`${API_URL}/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, password })
            });
            
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.message);
            }
            
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            
            msgDiv.className = 'message success';
            msgDiv.textContent = 'Login successful! Redirecting...';
            
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 1000);
        } catch (err) {
            msgDiv.className = 'message error';
            msgDiv.textContent = err.message;
        }
    });
}