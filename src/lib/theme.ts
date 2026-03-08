export type TimePeriod = 'morning' | 'afternoon' | 'evening' | 'night';

export function getTimePeriod(): TimePeriod {
  const h = new Date().getHours();
  if (h >= 6 && h < 12) return 'morning';
  if (h >= 12 && h < 17) return 'afternoon';
  if (h >= 17 && h < 21) return 'evening';
  return 'night';
}

const greetings: Record<TimePeriod, string[]> = {
  morning: [
    '좋은 아침이야',
    '새로운 하루, 시작하자',
    '아침 커피 한 잔의 여유',
  ],
  afternoon: [
    '오후도 힘내자',
    '점심 먹었어? 파이팅',
    '한낮의 집중 타임',
  ],
  evening: [
    '오늘도 고생했어',
    '저녁 노을이 예쁜 시간',
    '하루 마무리, 잘 했어',
  ],
  night: [
    '편한 밤 되길',
    '밤의 고요함 속에서',
    '오늘도 수고했어, 좋은 꿈',
  ],
};

export function getGreeting(period: TimePeriod): string {
  const list = greetings[period];
  return list[Math.floor(Math.random() * list.length)];
}
