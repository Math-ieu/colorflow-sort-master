import { ViewStyle, Platform } from 'react-native';

export const Shadows = {
  glassCard: Platform.select<ViewStyle>({
    web: {
      boxShadow: '0 12px 32px rgba(30, 30, 46, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.9)',
      backdropFilter: 'blur(16px)',
    } as any,
    default: {
      shadowColor: '#1E1E2E',
      shadowOffset: { width: 0, height: 8 },
      shadowOpacity: 0.1,
      shadowRadius: 16,
      elevation: 6,
    },
  }) as ViewStyle,

  vesselGlow: (color = 'rgba(78, 205, 196, 0.45)'): ViewStyle =>
    Platform.select<ViewStyle>({
      web: {
        boxShadow: `0 0 20px ${color}, 0 8px 24px rgba(30, 30, 46, 0.08)`,
      } as any,
      default: {
        shadowColor: color,
        shadowOffset: { width: 0, height: 0 },
        shadowOpacity: 0.8,
        shadowRadius: 14,
        elevation: 8,
      },
    }) as ViewStyle,

  vesselResting: Platform.select<ViewStyle>({
    web: {
      boxShadow: '0 8px 18px rgba(30, 30, 46, 0.06), inset 1px 1px 2px rgba(255, 255, 255, 0.9)',
    } as any,
    default: {
      shadowColor: '#1E1E2E',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.08,
      shadowRadius: 8,
      elevation: 4,
    },
  }) as ViewStyle,

  pillBadge: Platform.select<ViewStyle>({
    web: {
      boxShadow: '0 2px 8px rgba(30, 30, 46, 0.06)',
    } as any,
    default: {
      shadowColor: '#1E1E2E',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.06,
      shadowRadius: 4,
      elevation: 2,
    },
  }) as ViewStyle,
};
