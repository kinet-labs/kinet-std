import { Blockchain } from '@btc-vision/btc-runtime/runtime';
import { revertOnError } from '@btc-vision/btc-runtime/runtime/abort/abort';
import { KntBridge } from './KntBridge';

// DO NOT TOUCH THIS.
Blockchain.contract = new KntBridge();
revertOnError();
