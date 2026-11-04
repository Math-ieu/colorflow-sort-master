import { TextStyle, Platform } from 'react-native';

const fontFamily = Platform.select({
  ios: 'System',
  android: 'sans-serif-medium',
  default: 'Rubik, system-ui, -apple-system, sans-serif',
});

export const Typography: Record<string, TextStyle> = {
  headlineXl: {
    fontFamily,
    fontSize: 34,
    fontWeight: '800',
    lineHeight: 40,
    letterSpacing: -0.5,
  },
  headlineLg: {
    fontFamily,
    fontSize: 26,
    fontWeight: '700',
    lineHeight: 32,
  },
  headlineMd: {
    fontFamily,
    fontSize: 20,
    fontWeight: '700',
    lineHeight: 26,
  },
  bodyLg: {
    fontFamily,
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 22,
  },
  bodyMd: {
    fontFamily,
    fontSize: 14,
    fontWeight: '500',
    lineHeight: 20,
  },
  labelLg: {
    fontFamily,
    fontSize: 15,
    fontWeight: '700',
    lineHeight: 18,
  },
  labelMd: {
    fontFamily,
    fontSize: 13,
    fontWeight: '600',
    lineHeight: 16,
  },
  labelSm: {
    fontFamily,
    fontSize: 11,
    fontWeight: '700',
    lineHeight: 14,
  },
};
