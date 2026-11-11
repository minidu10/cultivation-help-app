// Line icons in one style, standing in for the Material icons the Android app
// uses, so a figure or a record carries the same symbol on both.

function Icon({ size = 20, children, ...rest }) {
  return (
    <svg aria-hidden="true" width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" style={{ flexShrink: 0, display: 'block' }} {...rest}>
      {children}
    </svg>
  )
}

export const PaymentsIcon = (p) => <Icon {...p}><rect x="3" y="6" width="18" height="13" rx="2" /><path d="M3 10h18" /><path d="M7 15h3" /></Icon>
export const ReceiptIcon = (p) => <Icon {...p}><path d="M6 3h12v18l-3-2-3 2-3-2-3 2z" /><path d="M9 8h6" /><path d="M9 12h6" /></Icon>
export const TrendUpIcon = (p) => <Icon {...p}><path d="M3 17l6-6 4 4 8-8" /><path d="M15 7h6v6" /></Icon>
export const TrendDownIcon = (p) => <Icon {...p}><path d="M3 7l6 6 4-4 8 8" /><path d="M15 17h6v-6" /></Icon>
export const SproutIcon = (p) => <Icon {...p}><path d="M12 21v-9" /><path d="M12 12C12 8 9 6 5 6c0 4 3 6 7 6z" /><path d="M12 10c0-3.5 2.5-6 7-6 0 4-3 6-7 6z" /></Icon>
export const BoxIcon = (p) => <Icon {...p}><path d="M3 7.5L12 3l9 4.5v9L12 21l-9-4.5z" /><path d="M3 7.5l9 4.5 9-4.5" /><path d="M12 12v9" /></Icon>
export const ListIcon = (p) => <Icon {...p}><path d="M9 6h12" /><path d="M9 12h12" /><path d="M9 18h12" /><path d="M4 6h.01" /><path d="M4 12h.01" /><path d="M4 18h.01" /></Icon>
export const TagIcon = (p) => <Icon {...p}><path d="M3 12V4h8l10 10-8 8z" /><circle cx="7.5" cy="7.5" r="1.2" /></Icon>
export const PieIcon = (p) => <Icon {...p}><path d="M12 3a9 9 0 1 0 9 9h-9z" /><path d="M15 3.5A9 9 0 0 1 20.5 9H15z" /></Icon>
export const PencilIcon = (p) => <Icon {...p}><path d="M4 20h4L19 9l-4-4L4 16z" /><path d="M13.5 6.5l4 4" /></Icon>
export const TrashIcon = (p) => <Icon {...p}><path d="M4 7h16" /><path d="M10 11v6" /><path d="M14 11v6" /><path d="M6 7l1 13h10l1-13" /><path d="M9 7V4h6v3" /></Icon>
export const PlusIcon = (p) => <Icon {...p}><path d="M12 5v14" /><path d="M5 12h14" /></Icon>
export const SendIcon = (p) => <Icon {...p}><path d="M4 12l16-8-6 16-2.5-6.5z" /><path d="M11.5 13.5L20 4" /></Icon>
export const CheckCircleIcon = (p) => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M8 12.5l2.5 2.5L16 9.5" /></Icon>
export const BellIcon = (p) => <Icon {...p}><path d="M6 16v-5a6 6 0 0 1 12 0v5l2 2H4z" /><path d="M10 20a2 2 0 0 0 4 0" /></Icon>
export const RefreshIcon = (p) => <Icon {...p}><path d="M20 11a8 8 0 1 0-2.3 5.7" /><path d="M20 4v7h-7" /></Icon>

// Expense categories
export const BagIcon = (p) => <Icon {...p}><path d="M6 8h12l1.5 12h-15z" /><path d="M9 8V6a3 3 0 0 1 6 0v2" /></Icon>
export const PeopleIcon = (p) => <Icon {...p}><circle cx="9" cy="8" r="3" /><path d="M3 20a6 6 0 0 1 12 0" /><path d="M16 5a3 3 0 0 1 0 6" /><path d="M18 14.5a5 5 0 0 1 3 5.5" /></Icon>
export const TruckIcon = (p) => <Icon {...p}><path d="M3 6h11v10H3z" /><path d="M14 9h4l3 3v4h-7" /><circle cx="7" cy="17.5" r="1.8" /><circle cx="17" cy="17.5" r="1.8" /></Icon>
export const WrenchIcon = (p) => <Icon {...p}><path d="M15 4a5 5 0 0 0-4.6 6.9L4 17.3V20h2.7l6.4-6.4A5 5 0 0 0 20 9l-3 1-2-2 1-3z" /></Icon>
export const SprayIcon = (p) => <Icon {...p}><path d="M8 10h6v11H8z" /><path d="M10 10V6h2v4" /><path d="M12 6h3" /><path d="M18 4h.01" /><path d="M20 6.5h.01" /><path d="M18 9h.01" /></Icon>
export const DropIcon = (p) => <Icon {...p}><path d="M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z" /></Icon>
export const DotsIcon = (p) => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M8 12h.01" /><path d="M12 12h.01" /><path d="M16 12h.01" /></Icon>
