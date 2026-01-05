const itemInput = document.getElementById('item-input');
const storeSelect = document.getElementById('store-select');
const addBtn = document.getElementById('add-btn');
const listsContainer = document.getElementById('lists-container');

document.addEventListener('DOMContentLoaded', loadData);

function saveData() {
    // We save the entire innerHTML of the container. 
    // This is the simplest way for your current setup!
    localStorage.setItem("shoppingListData", listsContainer.innerHTML);
}

function loadData() {
    const savedData = localStorage.getItem("shoppingListData");
    if (savedData) {
        listsContainer.innerHTML = savedData;
    }
}



// --- PART 1: ADDING ITEMS ---
addBtn.addEventListener('click', () => {
    const itemName = itemInput.value.trim();
    const storeName = storeSelect.value;

    if (itemName === "" || storeName === "") {
        alert("Please enter an item and select a store");
        return;
    }

    const storeId = `store-${storeName.replace(/\s+/g, '')}`;
    let storeDiv = document.getElementById(storeId);

    // If store doesn't exist, create it
    if (!storeDiv) {
        storeDiv = document.createElement('div');
        storeDiv.classList.add('store-list');
        storeDiv.id = storeId;

        const header = document.createElement('h3');
        header.innerText = storeName;

        const ul = document.createElement('ul');

        const clearBtn = document.createElement('button');
        clearBtn.innerText = "Delete List";
        clearBtn.className = "clear-btn";

        storeDiv.appendChild(header);
        storeDiv.appendChild(ul);
        storeDiv.appendChild(clearBtn);
        listsContainer.appendChild(storeDiv);
    }

    const ul = storeDiv.querySelector('ul');
    const li = document.createElement('li');
    
    // 1. Set the text
    // We put the text in a textNode so it sits nicely next to the close button
    li.appendChild(document.createTextNode(itemName));

    // 2. Create the Close Button (Span) immediately
    const span = document.createElement("SPAN");
    const txt = document.createTextNode("\u00D7"); // The "x" symbol
    span.className = "close";
    span.appendChild(txt);
    
    // 3. Append the close button to the LI
    li.appendChild(span);

    // 4. Add to list
    ul.appendChild(li);

    itemInput.value = '';
    itemInput.focus();

    saveData();
});

// --- PART 2: CLICKING ITEMS (The Event Delegation) ---
// We listen to the whole container. This catches clicks on ANY list, 
// even ones created after the page loaded.
listsContainer.addEventListener('click', function(e) {
    
    // ACTION 1: Did they click the "x" (Close button)?
    if (e.target.className === 'close') {
        // We want to hide/remove the LI, which is the parent of the span
        const div = e.target.parentElement;
        
        
        div.remove();
        saveData();
    }
    
    // ACTION 2: Did they click the List Item (to check it off)?
    else if (e.target.tagName === 'LI') {
        e.target.classList.toggle('checked');
        saveData();
    }

    // 3. CLICKED "CLEAR LIST" BUTTON
    else if (e.target.className === 'clear-btn') {
        if(confirm("Are you sure you want to remove this whole list?")) {
            // We find the parent (the store-list div) and remove it entirely
            const storeDiv = e.target.parentElement; 
            storeDiv.remove();
            saveData();
        }
    }

    const themeToggle = document.getElementById('theme-toggle');

//Check for saved theme in Local Storage
    const currentTheme = localStorage.getItem('theme');
    if (currentTheme) {
        document.documentElement.setAttribute('data-theme', currentTheme);
        themeToggle.textContent = currentTheme === 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode';
    }

//Toggle Logic
    themeToggle.addEventListener('click', () => {
    let theme = document.documentElement.getAttribute('data-theme');
    
    if (theme === 'dark') {
        document.documentElement.setAttribute('data-theme', 'light');
        localStorage.setItem('theme', 'light');
        themeToggle.textContent = '🌙 Dark Mode';
    } else {
        document.documentElement.setAttribute('data-theme', 'dark');
        localStorage.setItem('theme', 'dark');
        themeToggle.textContent = '☀️ Light Mode';
    }
});
    
}, false);