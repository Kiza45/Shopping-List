const itemInput = document.getElementById('item-input');
const storeSelect = document.getElementById('store-select');
const addBtn = document.getElementById('add-btn');
const listsContainer = document.getElementById('lists-container');
const themeToggle = document.getElementById('theme-toggle');
const htmlElement = document.documentElement;

// --- INITIALIZATION ---
document.addEventListener('DOMContentLoaded', () => {
    loadData();
    captureState();
    // Initialize Theme
    const savedTheme = localStorage.getItem('theme') || 'light';
    htmlElement.setAttribute('data-theme', savedTheme);
    updateToggleButton(savedTheme);
});

function saveData() {
    localStorage.setItem("shoppingListData", listsContainer.innerHTML);
}

function loadData() {
    const savedData = localStorage.getItem("shoppingListData");
    if (savedData) {
        listsContainer.innerHTML = savedData;
    }
}

// --- DARK MODE LOGIC (Fixed Brackets) ---
themeToggle.addEventListener('click', () => {
    captureState();
    const currentTheme = htmlElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    
    htmlElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateToggleButton(newTheme);
});

function updateToggleButton(theme) {
    themeToggle.textContent = theme === 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode';
}

// --- PART 1: ADDING ITEMS ---
addBtn.addEventListener('click', () => {
    captureState();
    const itemName = itemInput.value.trim();
    const storeName = storeSelect.value;

    if (itemName === "" || storeName === "") {
        alert("Please enter an item and select a store");
        return;
    }

    const storeId = `store-${storeName.replace(/\s+/g, '')}`;
    let storeDiv = document.getElementById(storeId);

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
    li.appendChild(document.createTextNode(itemName));

    const span = document.createElement("SPAN");
    span.innerText = "\u00D7";
    span.className = "close";
    li.appendChild(span);
    ul.appendChild(li);

    itemInput.value = '';
    itemInput.focus();
    saveData();
});




// List Interactions ---
listsContainer.addEventListener('click', function(e) {
    captureState();
    if (e.target.className === 'close') {
        e.target.parentElement.remove();
        saveData();
    } else if (e.target.tagName === 'LI') {
        e.target.classList.toggle('checked');
        saveData();
    } else if (e.target.className === 'clear-btn') {
        if(confirm("Are you sure you want to remove this whole list?")) {
            e.target.parentElement.remove();
            saveData();
        }
    }
});


//Undo Button functionality
let historyStack = [];
const undoButtonElement = document.getElementById('undo-button')

function captureState(){
    if (historyStack.length > 20){
        historyStack.shift();
    }
    historyStack.push(listsContainer.innerHTML);
}


function undo(){
    if(historyStack.length > 0){
        const previousState = historyStack.pop();
        listsContainer.innerHTML = previousState;
        saveData();
    }
    else{
        alert("Nothing to undo!")
    }
}

if (undoButtonElement) {
    undoButtonElement.addEventListener('click', undo);
}