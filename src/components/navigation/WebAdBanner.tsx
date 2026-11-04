import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { Colors } from '../../theme/colors';
import { audioManager } from '../../utils/audio';

export const WebAdBanner: React.FC = () => {
  return (
    <View style={styles.container}>
      <View style={styles.leftGroup}>
        <View style={styles.adTag}>
          <Text style={styles.adTagText}>AD</Text>
        </View>
        <Text style={styles.adTitle}>Water Sort 3D • Free Gift</Text>
      </View>

      <Pressable
        onPress={() => audioManager.playClick()}
        style={({ pressed }) => [
          styles.installBtn,
          { opacity: pressed ? 0.85 : 1 },
        ]}
      >
        <Text style={styles.installText}>Install</Text>
      </Pressable>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginHorizontal: 16,
    marginVertical: 8,
    backgroundColor: '#EBE8F8',
    borderRadius: 16,
    paddingVertical: 10,
    paddingHorizontal: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  leftGroup: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  adTag: {
    backgroundColor: '#DAD6EE',
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 6,
    marginRight: 8,
  },
  adTagText: {
    fontSize: 10,
    fontWeight: '900',
    color: '#363152',
  },
  adTitle: {
    fontSize: 12,
    fontWeight: '700',
    color: '#28233C',
  },
  installBtn: {
    backgroundColor: Colors.coralDeep,
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 9999,
  },
  installText: {
    fontSize: 12,
    fontWeight: '800',
    color: '#FFFFFF',
  },
});
