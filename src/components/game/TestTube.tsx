import React from 'react';
import {
  Pressable,
  View,
  Text,
  StyleSheet,
  Platform,
  Animated,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import {
  Tube,
  LiquidColor,
  VesselSkinId,
  FluidPaletteId,
} from '../../types/game';
import { Colors } from '../../theme/colors';
import { Shadows } from '../../theme/shadows';
import { LiquidLayer } from './LiquidLayer';
import { audioManager } from '../../utils/audio';

interface TestTubeProps {
  tube: Tube;
  index: number;
  isSelected: boolean;
  onPress: (index: number) => void;
  width?: number;
  height?: number;
  onLayout?: (e: any) => void;
  // Cosmetics & Accessibility
  vesselSkin?: VesselSkinId;
  paletteId?: FluidPaletteId;
  colorBlindMode?: boolean;
  isHintHighlighted?: boolean;
  // Animation props during pour
  isPouringSource?: boolean;
  isPouringTarget?: boolean;
  pouredCount?: number;
  isRight?: boolean;
  pourPhase?: Animated.Value;
  animTranslateX?: Animated.AnimatedInterpolation<string | number>;
  animTranslateY?: Animated.AnimatedInterpolation<string | number>;
  tiltAngle?: Animated.AnimatedInterpolation<string | number>;
  counterTiltAngle?: Animated.AnimatedInterpolation<string | number>;
  fillingColor?: LiquidColor | null;
  shakeAnim?: Animated.Value;
}

const SKIN_STYLES: Record<
  VesselSkinId,
  {
    lipBg: string;
    lipBorder: string;
    glassBg: string;
    glassBorder: string;
    bottomRadius: number;
    shineColor: string;
  }
> = {
  'tube-classic': {
    lipBg: 'rgba(255, 255, 255, 0.95)',
    lipBorder: 'rgba(230, 225, 245, 0.9)',
    glassBg: 'rgba(255, 255, 255, 0.52)',
    glassBorder: 'rgba(255, 255, 255, 0.95)',
    bottomRadius: 27,
    shineColor: 'rgba(255, 255, 255, 0.68)',
  },
  'tube-crystal': {
    lipBg: '#E0F2FE',
    lipBorder: '#38BDF8',
    glassBg: 'rgba(224, 242, 254, 0.45)',
    glassBorder: '#7DD3FC',
    bottomRadius: 14,
    shineColor: 'rgba(255, 255, 255, 0.88)',
  },
  'tube-gold': {
    lipBg: '#FEF3C7',
    lipBorder: '#F59E0B',
    glassBg: 'rgba(255, 251, 235, 0.50)',
    glassBorder: '#FBBF24',
    bottomRadius: 27,
    shineColor: 'rgba(254, 243, 199, 0.80)',
  },
  'tube-cyber': {
    lipBg: '#F3E8FF',
    lipBorder: '#A855F7',
    glassBg: 'rgba(243, 232, 255, 0.45)',
    glassBorder: '#C084FC',
    bottomRadius: 10,
    shineColor: 'rgba(233, 213, 255, 0.78)',
  },
};

export const TestTube: React.FC<TestTubeProps> = ({
  tube,
  index,
  isSelected,
  onPress,
  width = 54,
  height = 190,
  onLayout,
  vesselSkin = 'tube-classic',
  paletteId = 'palette-classic',
  colorBlindMode = false,
  isHintHighlighted = false,
  isPouringSource = false,
  isPouringTarget = false,
  pouredCount = 1,
  isRight = true,
  pourPhase,
  animTranslateX,
  animTranslateY,
  tiltAngle,
  counterTiltAngle,
  fillingColor,
  shakeAnim,
}) => {
  const segmentHeight = (height - 10) / tube.maxCapacity; // 45px
  const innerWidth = width - 4; // 50px
  const innerHeight = height - 4; // 186px
  const isEmpty = tube.colors.length === 0 && !fillingColor;
  const skin = SKIN_STYLES[vesselSkin] || SKIN_STYLES['tube-classic'];

  const isCompletedTube =
    !isPouringSource &&
    !isPouringTarget &&
    tube.colors.length === tube.maxCapacity &&
    tube.colors.every((c) => c === tube.colors[0]);

  const handlePress = () => {
    if (isPouringSource || isPouringTarget) return;
    audioManager.playTap();
    onPress(index);
  };

  const getContainerTransforms = () => {
    if (isPouringSource && animTranslateX && animTranslateY && tiltAngle) {
      return [
        { translateX: animTranslateX as any },
        { translateY: animTranslateY as any },
        { rotate: tiltAngle as any },
      ];
    }
    const transforms: any[] = [{ translateY: isSelected ? -18 : 0 }];
    if (shakeAnim) {
      transforms.push({ translateX: shakeAnim });
    }
    return transforms;
  };

  // Gravity-compensated liquid interior for the pouring source tube
  const renderPouringSourceLiquid = () => {
    if (!pourPhase || !counterTiltAngle) return null;

    const initialCount = tube.colors.length;
    const remainingCount = Math.max(0, initialCount - pouredCount);
    const restTopY = innerHeight - initialCount * segmentHeight;
    const afterPourTopY = innerHeight - remainingCount * segmentHeight;

    const surfaceAnchorX = pourPhase.interpolate({
      inputRange: [0, 0.85, 1, 2, 2.15, 3],
      outputRange: [
        innerWidth / 2,
        isRight ? 44 : 6,
        isRight ? 46 : 4,
        isRight ? 46 : 4,
        isRight ? 44 : 6,
        innerWidth / 2,
      ],
      extrapolate: 'clamp',
    });

    const surfaceAnchorY = pourPhase.interpolate({
      inputRange: [0, 0.85, 1, 2, 3],
      outputRange: [restTopY, 10, 5, 5, afterPourTopY],
      extrapolate: 'clamp',
    });

    const topDownIndices = Array.from(
      { length: initialCount },
      (_, i) => initialCount - 1 - i
    );

    return (
      <Animated.View
        style={[
          styles.liquidGravityContainer,
          {
            transform: [
              { translateX: surfaceAnchorX },
              { translateY: surfaceAnchorY },
              { rotate: counterTiltAngle as any },
            ],
          },
        ]}
      >
        {topDownIndices.map((colorIdx) => {
          const color = tube.colors[colorIdx];
          const isDrainingSegment = colorIdx >= initialCount - pouredCount;
          const isBottomSegment = colorIdx === 0;
          const isTopRemaining = colorIdx === initialCount - pouredCount - 1;
          const isVeryTop = colorIdx === initialCount - 1;

          const layerHeight = isDrainingSegment
            ? pourPhase.interpolate({
                inputRange: [0, 1, 2, 3],
                outputRange: [segmentHeight, segmentHeight * 0.62, 0, 0],
                extrapolate: 'clamp',
              })
            : pourPhase.interpolate({
                inputRange: [0, 1, 2, 3],
                outputRange: [
                  segmentHeight,
                  segmentHeight * 0.65 + (isBottomSegment ? 16 : 0),
                  segmentHeight * 0.52 + (isBottomSegment ? 18 : 0),
                  segmentHeight,
                ],
                extrapolate: 'clamp',
              });

          return (
            <Animated.View
              key={`${tube.id}-pour-seg-${colorIdx}`}
              style={{
                width: 260,
                height: layerHeight,
                overflow: 'hidden',
              }}
            >
              <LiquidLayer
                color={color}
                isBottom={isBottomSegment}
                isTop={isVeryTop || isTopRemaining}
                height={segmentHeight + 20}
                isReceiving={isVeryTop}
                paletteId={paletteId}
                colorBlindMode={colorBlindMode}
              />
            </Animated.View>
          );
        })}
      </Animated.View>
    );
  };

  return (
    <View
      onLayout={onLayout}
      style={[
        styles.tubeOuterWrapper,
        {
          zIndex: isPouringSource ? 100 : isSelected ? 20 : 2,
        },
      ]}
    >
      {/* Top glowing spark indicator when selected, completed, or AI hint highlighted */}
      <View
        style={[
          styles.topIndicator,
          {
            opacity:
              (isSelected && !isPouringSource) ||
              isCompletedTube ||
              isHintHighlighted
                ? 1
                : 0,
            transform: [{ translateY: isSelected ? -22 : 0 }],
          },
        ]}
      >
        {isCompletedTube ? (
          <View style={styles.completedBadgePill}>
            <Ionicons name="sparkles" size={10} color="#FFF" />
          </View>
        ) : isHintHighlighted ? (
          <View style={styles.hintBadgePill}>
            <Ionicons name="bulb" size={11} color="#78350F" />
          </View>
        ) : (
          <View style={styles.sparkCenter} />
        )}
      </View>

      <Animated.View
        style={[
          styles.container,
          {
            width,
            height,
            transform: getContainerTransforms(),
          },
          isSelected && !isPouringSource
            ? Shadows.vesselGlow()
            : Shadows.vesselResting,
        ]}
      >
        <Pressable
          onPress={handlePress}
          style={{ width: '100%', height: '100%' }}
        >
          {/* Golden cork/seal cap when tube is completed */}
          {isCompletedTube && (
            <View
              style={[
                styles.completedCorkCap,
                {
                  width: width - 4,
                  left: 2,
                },
              ]}
            >
              <Ionicons name="checkmark-circle" size={14} color="#FFFBEB" />
            </View>
          )}

          {/* Top Lip Rim of the glass flask */}
          <View
            style={[
              styles.lipFlange,
              {
                width: width + 6,
                left: -3,
                backgroundColor: skin.lipBg,
                borderColor: isCompletedTube
                  ? '#F59E0B'
                  : isHintHighlighted
                  ? '#F59E0B'
                  : skin.lipBorder,
              },
            ]}
          />

          {/* Glass body */}
          <View
            style={[
              styles.glassBody,
              {
                backgroundColor: skin.glassBg,
                borderRadius: skin.bottomRadius,
                borderTopLeftRadius: 4,
                borderTopRightRadius: 4,
                borderColor: isCompletedTube
                  ? 'rgba(251, 191, 36, 0.95)'
                  : isHintHighlighted
                  ? '#F59E0B'
                  : skin.glassBorder,
              },
            ]}
          >
            {/* Vertical glass specular shine strip */}
            <View
              style={[
                styles.specularShine,
                { backgroundColor: skin.shineColor },
              ]}
            />
            <View style={styles.rightRimHighlight} />

            {/* Liquid interior */}
            {isPouringSource && pourPhase && counterTiltAngle ? (
              renderPouringSourceLiquid()
            ) : (
              <View style={styles.liquidStack}>
                {tube.colors.map((color, colorIdx) => {
                  const isTopColor = colorIdx === tube.colors.length - 1;

                  return (
                    <LiquidLayer
                      key={`${tube.id}-seg-${colorIdx}`}
                      color={color}
                      isBottom={colorIdx === 0}
                      isTop={isTopColor && !fillingColor}
                      height={segmentHeight}
                      isCompletedTube={isCompletedTube && isTopColor}
                      paletteId={paletteId}
                      colorBlindMode={colorBlindMode}
                    />
                  );
                })}

                {/* If receiving liquid, render rising multi-segment layer at top of stack */}
                {isPouringTarget && fillingColor && pourPhase && (
                  <Animated.View
                    style={{
                      width: '100%',
                      height: pourPhase.interpolate({
                        inputRange: [0, 1.08, 2.02, 3],
                        outputRange: [
                          0,
                          0,
                          pouredCount * segmentHeight,
                          pouredCount * segmentHeight,
                        ],
                        extrapolate: 'clamp',
                      }),
                      overflow: 'hidden',
                    }}
                  >
                    <LiquidLayer
                      color={fillingColor}
                      isBottom={tube.colors.length === 0}
                      isTop={true}
                      height={pouredCount * segmentHeight}
                      isReceiving={true}
                      paletteId={paletteId}
                      colorBlindMode={colorBlindMode}
                    />
                  </Animated.View>
                )}
              </View>
            )}

            {/* Empty tube indicator */}
            {isEmpty && (
              <View style={styles.emptyIndicator}>
                <Ionicons
                  name="water-outline"
                  size={22}
                  color="rgba(156, 163, 175, 0.65)"
                />
                <Text style={styles.emptyText}>EMPTY</Text>
              </View>
            )}
          </View>
        </Pressable>
      </Animated.View>

      {/* Base drop shadow on shelf */}
      <View
        style={[
          styles.shelfShadow,
          {
            width: width * 0.85,
            opacity: isSelected || isPouringSource ? 0.2 : 0.6,
            transform: [{ scale: isSelected || isPouringSource ? 0.8 : 1 }],
          },
        ]}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  tubeOuterWrapper: {
    alignItems: 'center',
    position: 'relative',
    marginHorizontal: 5,
  },
  topIndicator: {
    height: 14,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 4,
  },
  sparkCenter: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: Colors.mint,
    ...Platform.select({
      web: {
        boxShadow: '0 0 10px #4ECDC4, 0 0 20px #4ECDC4',
      } as any,
    }),
  },
  completedBadgePill: {
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: Colors.gold,
    justifyContent: 'center',
    alignItems: 'center',
    ...Platform.select({
      web: {
        boxShadow: '0 2px 8px rgba(245, 158, 11, 0.45)',
      } as any,
    }),
  },
  hintBadgePill: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: '#FDE68A',
    borderWidth: 1.5,
    borderColor: '#F59E0B',
    justifyContent: 'center',
    alignItems: 'center',
  },
  container: {
    position: 'relative',
    alignItems: 'center',
    cursor: 'pointer' as any,
    userSelect: 'none' as any,
  },
  completedCorkCap: {
    position: 'absolute',
    top: -10,
    height: 12,
    borderTopLeftRadius: 6,
    borderTopRightRadius: 6,
    backgroundColor: '#F59E0B',
    borderWidth: 1,
    borderColor: '#FDE68A',
    zIndex: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  lipFlange: {
    position: 'absolute',
    top: -3,
    height: 6,
    borderRadius: 3,
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderWidth: 1,
    borderColor: 'rgba(230, 225, 245, 0.9)',
    zIndex: 10,
  },
  glassBody: {
    width: '100%',
    height: '100%',
    backgroundColor: 'rgba(255, 255, 255, 0.52)',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.95)',
    overflow: 'hidden',
    justifyContent: 'flex-end',
    position: 'relative',
  },
  specularShine: {
    position: 'absolute',
    top: 6,
    left: 4,
    width: 5,
    bottom: 22,
    backgroundColor: 'rgba(255, 255, 255, 0.68)',
    borderRadius: 3,
    zIndex: 15,
    pointerEvents: 'none',
  },
  rightRimHighlight: {
    position: 'absolute',
    top: 10,
    right: 3,
    width: 2,
    bottom: 26,
    backgroundColor: 'rgba(255, 255, 255, 0.38)',
    borderRadius: 1,
    zIndex: 15,
    pointerEvents: 'none',
  },
  liquidStack: {
    width: '100%',
    flexDirection: 'column-reverse',
    zIndex: 2,
  },
  liquidGravityContainer: {
    position: 'absolute',
    width: 260,
    height: 520,
    left: -130,
    top: -260,
    paddingTop: 260,
    alignItems: 'center',
    zIndex: 2,
  },
  emptyIndicator: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 3,
  },
  emptyText: {
    fontSize: 10,
    fontWeight: '800',
    color: 'rgba(156, 163, 175, 0.7)',
    letterSpacing: 0.5,
    marginTop: 4,
  },
  shelfShadow: {
    height: 8,
    borderRadius: 4,
    backgroundColor: 'rgba(140, 130, 180, 0.28)',
    marginTop: 6,
  },
});
