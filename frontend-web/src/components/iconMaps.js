// Which icon stands for each expense category and reminder type, matching
// the Android app's choices.
import { BagIcon, BellIcon, BoxIcon, DotsIcon, DropIcon, PeopleIcon, SprayIcon, SproutIcon, TruckIcon, WrenchIcon } from './Icons'

export const CATEGORY_ICONS = {
  FERTILIZER: BagIcon, LABOR: PeopleIcon, TRANSPORT: TruckIcon, EQUIPMENT: WrenchIcon,
  SEEDS: SproutIcon, PESTICIDES: SprayIcon, IRRIGATION: DropIcon, MISCELLANEOUS: DotsIcon,
}

export const REMINDER_ICONS = {
  FERTILIZER: BagIcon, IRRIGATION: DropIcon, PEST_CONTROL: SprayIcon, HARVEST: BoxIcon, OTHER: BellIcon,
}
