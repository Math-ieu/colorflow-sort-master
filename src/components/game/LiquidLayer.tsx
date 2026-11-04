import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { LiquidColor, FluidPaletteId } from '../../types/game';
import { Colors } from '../../theme/colors';

interface LiquidLayerProps {
  color: LiquidColor;
  isBottom: boolean;
  isTop: boolean;
  height: number;
  isReceiving?: boolean;
  isCompletedTube?: boolean;
  paletteId?: FluidPaletteId;
  colorBlindMode?: boolean;
}

export type ColorScheme = {
  bg: string;
  shine: string;
  shade: string;
  meniscus: string;
  symbol: string;
};

export const PALETTE_SCHEMES: Record<
  FluidPaletteId,
  Record<LiquidColor, ColorScheme>
> = {
  'palette-classic': {
    coral: {
      bg: Colors.coral,
      shine: '#FF9E9E',
      shade: Colors.coralShade,
      meniscus: '#FFB8B8',
      symbol: '●',
    },
    mint: {
      bg: Colors.mint,
      shine: '#88F2EA',
      shade: Colors.mintShade,
      meniscus: '#B0FAF4',
      symbol: '▲',
    },
    yellow: {
      bg: Colors.sunnyYellow,
      shine: '#FFF5AD',
      shade: Colors.yellowShade,
      meniscus: '#FFF9C8',
      symbol: '★',
    },
    violet: {
      bg: '#B8AFF2',
      shine: '#DDD8FF',
      shade: '#9A8EE3',
      meniscus: '#EAE6FF',
      symbol: '◆',
    },
    emerald: {
      bg: Colors.emerald,
      shine: '#6EE7B7',
      shade: Colors.emeraldShade,
      meniscus: '#A7F3D0',
      symbol: '■',
    },
    gold: {
      bg: Colors.gold,
      shine: '#FCD34D',
      shade: Colors.goldShade,
      meniscus: '#FDE68A',
      symbol: '♥',
    },
  },
  'theme-neon': {
    coral: {
      bg: '#FF2A85',
      shine: '#FF7EB6',
      shade: '#D60059',
      meniscus: '#FF9EC7',
      symbol: '●',
    },
    mint: {
      bg: '#00F5D4',
      shine: '#80FFED',
      shade: '#00C2A8',
      meniscus: '#B8FFF5',
      symbol: '▲',
    },
    yellow: {
      bg: '#FEE440',
      shine: '#FFF29C',
      shade: '#D9BC00',
      meniscus: '#FFF8C4',
      symbol: '★',
    },
    violet: {
      bg: '#9B5DE5',
      shine: '#C69FF5',
      shade: '#7635C7',
      meniscus: '#DEC4FA',
      symbol: '◆',
    },
    emerald: {
      bg: '#00BBF9',
      shine: '#8AE2FF',
      shade: '#008EC2',
      meniscus: '#BAEFFF',
      symbol: '■',
    },
    gold: {
      bg: '#FF9F1C',
      shine: '#FFCA80',
      shade: '#D47A00',
      meniscus: '#FFE0B5',
      symbol: '♥',
    },
  },
  'palette-ocean': {
    coral: {
      bg: '#E11D48',
      shine: '#FB7185',
      shade: '#BE123C',
      meniscus: '#FDA4AF',
      symbol: '●',
    },
    mint: {
      bg: '#0EA5E9',
      shine: '#7DD3FC',
      shade: '#0284C7',
      meniscus: '#BAE6FD',
      symbol: '▲',
    },
    yellow: {
      bg: '#FACC15',
      shine: '#FEF08A',
      shade: '#CA8A04',
      meniscus: '#FEF9C3',
      symbol: '★',
    },
    violet: {
      bg: '#6366F1',
      shine: '#A5B4FC',
      shade: '#4338CA',
      meniscus: '#C7D2FE',
      symbol: '◆',
    },
    emerald: {
      bg: '#14B8A6',
      shine: '#5EEAD4',
      shade: '#0F766E',
      meniscus: '#99F6E4',
      symbol: '■',
    },
    gold: {
      bg: '#D97706',
      shine: '#FBBF24',
      shade: '#92400E',
      meniscus: '#FDE68A',
      symbol: '♥',
    },
  },
};

export const LIQUID_COLOR_SCHEMES = PALETTE_SCHEMES['palette-classic'];

export const LiquidLayer: React.FC<LiquidLayerProps> = ({
  color,
  isBottom,
  isTop,
  height,
  isReceiving = false,
  isCompletedTube = false,
  paletteId = 'palette-classic',
  colorBlindMode = false,
}) => {
  const activePalette = PALETTE_SCHEMES[paletteId] || PALETTE_SCHEMES['palette-classic'];
  const scheme = activePalette[color] || activePalette.coral;

  const waveAnim = useRef(new Animated.Value(0)).current;
  const bubbleAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (isReceiving || isCompletedTube) {
      const waveLoop = Animated.loop(
        Animated.sequence([
          Animated.timing(waveAnim, {
            toValue: 1,
            duration: 240,
            useNativeDriver: true,
          }),
          Animated.timing(waveAnim, {
            toValue: -1,
            duration: 240,
            useNativeDriver: true,
          }),
        ])
      );
      const bubbleLoop = Animated.loop(
        Animated.timing(bubbleAnim, {
          toValue: 1,
          duration: 550,
          useNativeDriver: true,
        })
      );
      waveLoop.start();
      bubbleLoop.start();
      return () => {
        waveLoop.stop();
        bubbleLoop.stop();
      };
    } else {
      waveAnim.setValue(0);
      bubbleAnim.setValue(0);
    }
  }, [isReceiving, isCompletedTube]);

  const waveTranslateX = waveAnim.interpolate({
    inputRange: [-1, 1],
    outputRange: [-6, 6],
  });

  const waveScaleY = waveAnim.interpolate({
    inputRange: [-1, 0, 1],
    outputRange: [0.85, 1.35, 0.85],
  });

  const bubbleTranslateY = bubbleAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [Math.max(12, height - 4), 2],
  });

  const bubbleOpacity = bubbleAnim.interpolate({
    inputRange: [0, 0.2, 0.8, 1],
    outputRange: [0, 0.85, 0.85, 0],
  });

  return (
    <View
      style={[
        styles.segment,
        {
          height,
          backgroundColor: scheme.bg,
        },
      ]}
    >
      {/* Subtle bottom depth line between distinct layers */}
      {!isBottom && (
        <View
          style={[
            styles.layerInterfaceLine,
            { backgroundColor: scheme.shade },
          ]}
        />
      )}

      {/* Color-Blind Accessibility Symbol Watermark */}
      {colorBlindMode && height >= 25 && (
        <View style={styles.symbolOverlay} pointerEvents="none">
          <Text style={styles.symbolText}>{scheme.symbol}</Text>
        </View>
      )}

      {/* Top free-surface meniscus with wave agitation when pouring */}
      {isTop && (
        <Animated.View
          style={[
            styles.meniscusSurface,
            {
              backgroundColor: scheme.meniscus,
              transform: [
                { translateX: waveTranslateX },
                { scaleY: isReceiving ? waveScaleY : 1 },
              ],
            },
          ]}
        >
          <View
            style={[
              styles.meniscusCoreHighlight,
              { backgroundColor: 'rgba(255, 255, 255, 0.65)' },
            ]}
          />
        </Animated.View>
      )}

      {/* Effervescent micro-bubbles when receiving liquid or completed */}
      {(isReceiving || isCompletedTube) && (
        <View style={styles.bubblesLayer} pointerEvents="none">
          <Animated.View
            style={[
              styles.bubble,
              {
                left: '44%',
                width: 5,
                height: 5,
                opacity: bubbleOpacity,
                transform: [{ translateY: bubbleTranslateY }],
              },
            ]}
          />
          <Animated.View
            style={[
              styles.bubble,
              {
                left: '55%',
                width: 3.5,
                height: 3.5,
                opacity: bubbleOpacity,
                transform: [
                  {
                    translateY: bubbleAnim.interpolate({
                      inputRange: [0, 1],
                      outputRange: [Math.max(8, height * 0.7), 0],
                    }),
                  },
                ],
              },
            ]}
          />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  segment: {
    width: '100%',
    position: 'relative',
    overflow: 'hidden',
  },
  layerInterfaceLine: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 1.5,
    opacity: 0.3,
  },
  symbolOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
  },
  symbolText: {
    fontSize: 13,
    fontWeight: '900',
    color: 'rgba(25, 20, 45, 0.42)',
  },
  meniscusSurface: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 5,
    borderRadius: 3,
    justifyContent: 'center',
    alignItems: 'center',
  },
  meniscusCoreHighlight: {
    width: '65%',
    height: 2,
    borderRadius: 1,
  },
  bubblesLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  bubble: {
    position: 'absolute',
    borderRadius: 99,
    backgroundColor: 'rgba(255, 255, 255, 0.75)',
  },
});
