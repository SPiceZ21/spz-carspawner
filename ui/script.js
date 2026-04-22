let vehicles = [];

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'show') {
        document.getElementById('app').style.display = 'flex';
        vehicles = data.vehicles;
        renderVehicles(vehicles);
    } else if (data.type === 'hide') {
        document.getElementById('app').style.display = 'none';
    }
});

function renderVehicles(list) {
    const container = document.getElementById('vehicle-list');
    container.innerHTML = '';

    list.forEach(vehicle => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        card.onclick = () => spawnVehicle(vehicle.model);

        card.innerHTML = `
            <div class="card-info">
                <div class="card-label">${vehicle.label}</div>
                <div class="card-model">${vehicle.model.toUpperCase()}</div>
            </div>
            <div class="card-accent"></div>
        `;

        container.appendChild(card);
    });
}

function filterVehicles() {
    const query = document.getElementById('search-input').value.toLowerCase();
    const filtered = vehicles.filter(v => 
        v.label.toLowerCase().includes(query) || 
        v.model.toLowerCase().includes(query)
    );
    renderVehicles(filtered);
}

function spawnVehicle(model) {
    fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            model: model
        })
    }).then(resp => resp.json());
}

window.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).then(resp => resp.json());
    }
});
