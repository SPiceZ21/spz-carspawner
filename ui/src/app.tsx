import { useState, useEffect } from 'preact/hooks'
import { ChevronRight, CarFront, Search } from 'lucide-preact'
import { Button } from './components/Button'
import { Badge } from './components/Badge'
import { Input } from './components/Input'
import './components/Button.css'
import './components/Badge.css'
import './components/Input.css'

interface Vehicle {
  model: string
  label: string
}

function nuiPost(endpoint: string, data: object = {}) {
  fetch(`https://${GetParentResourceName()}/${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  }).catch(() => {})
}

function VehicleRow({ vehicle, onSpawn }: { vehicle: Vehicle; onSpawn: (model: string) => void }) {
  return (
    <div class="vehicle-row" onClick={() => onSpawn(vehicle.model)}>
      <div>
        <div class="vehicle-name">{vehicle.label}</div>
        <div class="vehicle-model">{vehicle.model.toUpperCase()}</div>
      </div>
      <ChevronRight size={14} color="var(--gray-500)" />
    </div>
  )
}

export function App() {
  const [visible, setVisible] = useState(false)
  const [vehicles, setVehicles] = useState<Vehicle[]>([])
  const [query, setQuery] = useState('')

  useEffect(() => {
    const handler = (e: MessageEvent) => {
      if (e.data.type === 'show') {
        setVehicles(e.data.vehicles || [])
        setQuery('')
        setVisible(true)
      } else if (e.data.type === 'hide') {
        setVisible(false)
      }
    }
    window.addEventListener('message', handler)
    return () => window.removeEventListener('message', handler)
  }, [])

  useEffect(() => {
    if (!visible) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') doClose()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [visible])

  const doClose = () => {
    nuiPost('close')
    setVisible(false)
  }

  const spawn = (model: string) => {
    nuiPost('spawnVehicle', { model })
    setVisible(false)
  }

  const filtered = vehicles.filter(
    v =>
      v.label.toLowerCase().includes(query.toLowerCase()) ||
      v.model.toLowerCase().includes(query.toLowerCase()),
  )

  if (!visible) return null

  return (
    <div class="depot-overlay">
      <div class="depot-panel">
        <div class="depot-header">
          <div class="depot-header-top">
            <span class="depot-icon">
              <CarFront size={18} />
            </span>
            <div>
              <div class="spz-eyebrow">Vehicle Depot</div>
              <div class="depot-title">Select Machine</div>
            </div>
          </div>
          <div class="depot-search-wrap">
            <span class="depot-search-icon">
              <Search size={13} />
            </span>
            <Input
              style={{ paddingLeft: '30px' }}
              placeholder="Search vehicles…"
              value={query}
              onInput={(e: Event) => setQuery((e.target as HTMLInputElement).value)}
              autoFocus
            />
          </div>
        </div>

        <div class="depot-list">
          {filtered.length === 0 ? (
            <div class="depot-empty">No vehicles found</div>
          ) : (
            filtered.map(v => <VehicleRow key={v.model} vehicle={v} onSpawn={spawn} />)
          )}
        </div>

        <div class="depot-footer">
          <Badge variant="secondary">Esc</Badge>
          <span style={{ fontSize: 11, color: 'var(--gray-400)' }}>close</span>
          <span class="depot-footer-sep">·</span>
          <Badge variant="secondary">Click</Badge>
          <span style={{ fontSize: 11, color: 'var(--gray-400)' }}>deploy</span>
          <div style={{ marginLeft: 'auto' }}>
            <Badge variant="primary">{filtered.length} vehicles</Badge>
          </div>
        </div>
      </div>
    </div>
  )
}
