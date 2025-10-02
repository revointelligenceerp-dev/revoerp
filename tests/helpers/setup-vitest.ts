import '@testing-library/jest-dom';
import { TextEncoder, TextDecoder } from 'util';

// Polyfill para TextEncoder/TextDecoder que são esperados pelo jsdom mas não estão no ambiente Node.js por padrão
if (typeof global.TextEncoder === 'undefined') {
  (global as any).TextEncoder = TextEncoder;
}
if (typeof global.TextDecoder === 'undefined') {
  (global as any).TextDecoder = TextDecoder;
}
