import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Platform } from 'react-native';
import { LiquidColor, FluidPaletteId } from '../../types/game';
import { PALETTE_SCHEMES } from './LiquidLayer';

interface FluidStreamProps {
  x: number;
  startY: number;
  initialEndY: number;
  finalEndY: number;
  color: LiquidColor;
  pourPhase: Animated.Value;
  paletteId?: FluidPaletteId;
}

export const FluidStream: React.FC<FluidStreamProps> = ({
  x,
  startY,
  initialEndY,
  finalEndY,
  color,
  pourPhase,
  paletteId = 'palette-classic',
}) => {
  const shimmerAnim = useRef(new Animated.Value(0)).current;
  const activePalette = PALETTE_SCHEMES[paletteId] || PALETTE_SCHEMES['palette-classic'];
  const scheme = activePalette[color] || activePalette.coral;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(shimmerAnim, {
          toValue: 1,
          duration: 110,
          useNativeDriver: false,
        }),
        Animated.timing(shimmerAnim, {
          toValue: -1,
          duration: 110,
          useNativeDriver: false,
        }),
      ])
    );
    loop.start();
    return () => loop.stop();
  }, []);

  const currentTopY = pourPhase.interpolate({
    inputRange: [0, 0.92, 2.0, 2.28, 3.0],
    outputRange: [startY, startY, startY, finalEndY, finalEndY],
    extrapolate: 'clamp',
  });

  const currentBottomY = pourPhase.interpolate({
    inputRange: [0, 0.92, 1.1, 2.0, 2.28, 3.0],
    outputRange: [startY, startY, initialEndY, finalEndY, finalEndY, finalEndY],
    extrapolate: 'clamp',
  });

  const streamHeight = Animated.subtract(currentBottomY, currentTopY);

  const streamOpacity = pourPhase.interpolate({
    inputRange: [0, 0.9, 0.96, 2.24, 2.3, 3.0],
    outputRange: [0, 0, 1, 1, 0, 0],
    extrapolate: 'clamp',
  });

  const baseWidth = pourPhase.interpolate({
    inputRange: [0, 0.95, 1.15, 1.85, 2.15, 2.3],
    outputRange: [2, 9, 8.5, 7.5, 3, 1],
    extrapolate: 'clamp',
  });

  const splashOpacity = pourPhase.interpolate({
    inputRange: [0, 1.06, 1.12, 2.1, 2.26, 3.0],
    outputRange: [0, 0, 1, 1, 0, 0],
    extrapolate: 'clamp',
  });

  const splashScale = shimmerAnim.interpolate({
    inputRange: [-1, 1],
    outputRange: [0.85, 1.25],
  });

  return (
    <Animated.View
      pointerEvents="none"
      style={[
        styles.wrapper,
        {
          left: x - 16,
          opacity: streamOpacity,
        },
      ]}
    >
      {/* Pouring lip meniscus bead right at the spout */}
      <Animated.View
        style={[
          styles.spoutBead,
          {
            top: currentTopY,
            backgroundColor: scheme.bg,
            opacity: pourPhase.interpolate({
              inputRange: [0, 0.92, 1.0, 1.98, 2.05, 3],
              outputRange: [0, 0, 1, 1, 0, 0],
            }),
          },
        ]}
      />

      {/* Continuous Gravity Stream */}
      <Animated.View
        style={[
          styles.streamColumn,
          {
            top: currentTopY,
            height: streamHeight,
            width: baseWidth,
            backgroundColor: scheme.bg,
            ...Platform.select({
              web: {
                boxShadow: `0 0 10px ${scheme.shine}`,
              } as any,
            }),
          },
        ]}
      >
        <View
          style={[
            styles.streamCore,
            { backgroundColor: scheme.meniscus },
          ]}
        />
      </Animated.View>

      {/* Surface Impact Crown / Splash Ripple at the rising target surface */}
      <Animated.View
        style={[
          styles.impactSplash,
          {
            top: Animated.subtract(currentBottomY, 5),
            opacity: splashOpacity,
            backgroundColor: scheme.meniscus,
            borderColor: scheme.shine,
            transform: [{ scaleX: splashScale }],
          },
        ]}
      />
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    top: 0,
    width: 32,
    alignItems: 'center',
    zIndex: 85,
  },
  spoutBead: {
    position: 'absolute',
    width: 11,
    height: 11,
    borderRadius: 6,
    marginTop: -3,
  },
  streamColumn: {
    position: 'absolute',
    borderRadius: 6,
    alignItems: 'center',
    overflow: 'hidden',
  },
  streamCore: {
    width: 2.5,
    height: '100%',
    borderRadius: 2,
    opacity: 0.85,
  },
  impactSplash: {
    position: 'absolute',
    width: 22,
    height: 8,
    borderRadius: 8,
    borderWidth: 1.5,
  },
});
