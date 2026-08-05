export function formatDateISO(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function getMonthDays(year: number, monthIndex: number): Date[] {
  const days: Date[] = [];
  const firstDayOfMonth = new Date(year, monthIndex, 1);
  const startDayOfWeek = firstDayOfMonth.getDay(); // 0 (Sun) to 6 (Sat)

  // Start from Sunday preceding the 1st of month
  const startDate = new Date(year, monthIndex, 1 - startDayOfWeek);

  // We show 5 or 6 weeks (35 or 42 days)
  for (let i = 0; i < 42; i++) {
    const d = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + i);
    days.push(d);
  }

  return days;
}

export function getWeekDays(referenceDate: Date): Date[] {
  const days: Date[] = [];
  const dayOfWeek = referenceDate.getDay(); // 0 (Sun) to 6 (Sat)
  const sunday = new Date(referenceDate.getFullYear(), referenceDate.getMonth(), referenceDate.getDate() - dayOfWeek);

  for (let i = 0; i < 7; i++) {
    const d = new Date(sunday.getFullYear(), sunday.getMonth(), sunday.getDate() + i);
    days.push(d);
  }

  return days;
}

export const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

export const WEEKDAY_NAMES = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
