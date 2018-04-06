goog.provide('dtv.ui.Keyboard');

//************** Libs ****************
goog.require('dtv.io.Remote');
goog.require('goog.events.KeyCodes');

/**
 * Show the keyboard
 * @constructor
 *
 * @param {!string}   containerId      The keyboard container
 * @param {!string}   keyboardBgSrc    The image source of keyboard
 * @param {!number}   maxCharLength    The max number of character of text box
 * @param {!Function} callback         Callback when use press enter
 * @param {Function=} lostFocusCB      Callback when keyboard lost focus
 * @param {Function=} errorCallback    Callback when number of chars exceed the max length
 */
dtv.ui.Keyboard = function(containerId, keyboardBgSrc, maxCharLength, callback, lostFocusCB, errorCallback) {
	this.cb_ = callback;
	this.lostFocusCB_ = lostFocusCB;
	this.errorCallback_ = errorCallback;
	this.maxCharLength_ = maxCharLength;
	this.keyboardBgSrc_ = keyboardBgSrc;

	// Init the keyboard
	this.domId_ = containerId;
	var container = document.getElementById(this.domId_);
	if (container != null) {
		this.keyboardDom_ = document.createElement('img');
		this.keyboardDom_.classList.add('keyboard');
		this.keyboardDom_.onload = goog.bind(this.handleKeyboardLoaded_, this);
		this.keyboardDom_.style.top = '0px';
		this.keyboardDom_.style.left = '0px';
		this.keyboardDom_.style.width = '100%';
		this.keyboardDom_.style.height = '100%';
		container.appendChild(this.keyboardDom_);

		this.keyboardHLDom_ = document.createElement('div');
		this.keyboardHLDom_.classList.add('keyboard-highlighter');
		container.appendChild(this.keyboardHLDom_);

		this.textField_ = document.createElement('input');
		this.textField_.classList.add('text-field');
		container.appendChild(this.textField_);
	}
};


/**
 * List of key that force focus to enter when pressed
 * @type {Array.<string>}
 * @const
 */
dtv.ui.Keyboard.NAVIGATION_KEY = ['@GMAIL', '@YAHOO', '@HOTMAIL', '@AOL', '.COM'];

/**
 * Dot COM value
 * @type {string}
 * @const
 */
dtv.ui.Keyboard.DOT_COM_STRING = '.COM';

/**
 * Enter key value
 * @type {string}
 * @const
 */
dtv.ui.Keyboard.ENTER_KEY_STRING = 'enter';

/**
 * Delete key value
 * @type {string}
 * @const
 */
dtv.ui.Keyboard.DELETE_KEY_STRING = 'del';

/**
 * Clear key value
 * @type {string}
 * @const
 */
dtv.ui.Keyboard.CLEAR_KEY_STRING = 'clear';

/**
 * The maximum index of row
 * @type {string}
 * @const
 */
dtv.ui.Keyboard.MAX_ROW_INDEX = 4;

dtv.ui.Keyboard.T9_KEYS = {
	'48': [' ', '0'],
	'49': ['1'],
	'50': ['A', 'B', 'C', '2'],
	'51': ['D', 'E', 'F', '3'],
	'52': ['G', 'H', 'I', '4'],
	'53': ['J', 'K', 'L', '5'],
	'54': ['M', 'N', 'O', '6'],
	'55': ['P', 'Q', 'R', 'S', '7'],
	'56': ['T', 'U', 'V', '8'],
	'57': ['W', 'X', 'Y', 'Z', '9']
};

/**
 * Show keyboard
 * @public
 */
dtv.ui.Keyboard.prototype.display = function() {
	UI.showEl(this.domId_);
	this.focus();
	this.clearText();
	this.hideHighlighter();
	this.keyboardDom_.src = this.keyboardBgSrc_;
};

/**
 * Hide the view
 * @public
 */
dtv.ui.Keyboard.prototype.dispose = function() {
	UI.hideEl(this.domId_);
	this.lostFocus();
	this.keyboardDom_.src = '';
};

/**
 * Handle when keyboard get focus
 * @public
 */
dtv.ui.Keyboard.prototype.focus = function() {
	this.showHighlighter();
	this.isFocus_ = true;
};

/**
 * Handle when keyboard lost focus
 * @public
 */
dtv.ui.Keyboard.prototype.lostFocus = function() {
	this.hideHighlighter();
	this.isFocus_ = false;
};

/**
 * Show the highlighter
 * @public
 */
dtv.ui.Keyboard.prototype.showHighlighter = function() {
	this.keyboardHLDom_.style.display = 'block';
};

/**
 * Hide the highlighter
 * @public
 */
dtv.ui.Keyboard.prototype.hideHighlighter = function() {
	this.keyboardHLDom_.style.display = 'none';
};


/**
 * Clear the text in entry field
 * @public
 */
dtv.ui.Keyboard.prototype.clearText = function() {
	this.row_ = 0;
	this.col_ = 0;
	this.maxRow_ = dtv.ui.Keyboard.MAX_ROW_INDEX;
	this.maxCol_ = this.getMaxCol_();
	this.prevKeyCode_ = null;
	this.T9Index_ = 0;

	this.currentText_ = '_';
	this.showText_();
	this.changeFocus_();
};

/**
 * Handle key press
 *
 * @param {!goog.events.KeyCodes}
 *            key The key that was pressed
 * @return {boolean} False to tell the STB that the application handled the key
 *         so middleware does nothing. True to tell the STB to handle the event
 * @public
 */
dtv.ui.Keyboard.prototype.keyHandler = function(key) {
	var keys = dtv.io.Remote;

	if (!this.isFocus_) return true;

	if (keys.NUMPAD.indexOf(key.keyCode) !== -1) this.T9Keyhandler_(key); //send key to T9 keyhandler if key is a number

	else if (key.keyCode == dtv.io.Remote.UP && this.row_ > 0) {
		var prevMaxCol = this.getMaxCol_(this.row_ - 1);
		if (this.maxCol_ != prevMaxCol) {
			this.col_ = Math.round((this.col_ / (this.maxCol_ - 1)) * (prevMaxCol - 1));
			if (this.col_ >= prevMaxCol) this.col_ = prevMaxCol - 1;
			//for cases where a row has only one column
			if (isNaN(this.col_)) this.col_ = 0;
		}

		this.row_--;
		this.maxCol_ = prevMaxCol;
		this.changeFocus_();
	} else if (key.keyCode == dtv.io.Remote.DOWN) {
		if (this.row_ < this.maxRow_ - 1) {
			var nextMaxCol = this.getMaxCol_(this.row_ + 1);
			if (this.maxCol_ != nextMaxCol) {
				this.col_ = Math.round((this.col_ / (this.maxCol_ - 1)) * (nextMaxCol - 1));
				if (this.col_ >= nextMaxCol) this.col_ = nextMaxCol - 1;
			}

			//probably needed for when different size enter/del buttons exist.
			/*if (this.col_ == this.maxCol_ - 1 && this.row_ < 3) {
				this.row_ = 3;
			} else {
				this.row_++;
			}*/

			this.row_++;
			this.maxCol_ = nextMaxCol;
			this.changeFocus_();
		} /*else {
			this.lostFocus();
			if (goog.isDefAndNotNull(this.lostFocusCB_) && goog.isFunction(this.lostFocusCB_)) {
				this.lostFocusCB_(this);
			}
		}*/
	} else if (key.keyCode == dtv.io.Remote.LEFT && this.col_ > 0) {
		this.col_--;
		this.changeFocus_();
	} else if (key.keyCode == dtv.io.Remote.RIGHT) {
		if(this.col_ < this.maxCol_ - 1) {
			this.col_++;
			this.changeFocus_();
		} else {
			this.lostFocus();
			if (goog.isDefAndNotNull(this.lostFocusCB_) && goog.isFunction(this.lostFocusCB_)) {
				this.lostFocusCB_(this);
			}
		}
	} else if (key.keyCode == dtv.io.Remote.SELECT) {
		this.onSelect_();
	}

	return false;
};

/**
 * Handling when user select a character
 * @private
 */
dtv.ui.Keyboard.prototype.onSelect_ = function() {
	clearTimeout(this.T9timeout);
	var character = dtv.ui.Keyboard.CONFIG[this.row_][this.col_]['value'];

	switch (character) {
		case dtv.ui.Keyboard.ENTER_KEY_STRING:
			if (goog.isDefAndNotNull(this.cb_) && goog.isFunction(this.cb_)) {
				this.cb_(this.currentText_);
			}
			break;
		case dtv.ui.Keyboard.DELETE_KEY_STRING:
			if (this.currentText_.length > 0) {
				this.removeUnderscore_();
				this.currentText_ = this.currentText_.substring(0, this.currentText_.length - 1);
				this.addUnderscore_();
				this.showText_();
			}
			break;
		case dtv.ui.Keyboard.CLEAR_KEY_STRING:
			this.clearText();
			this.showText_();
			break;
		default:
			this.removeUnderscore_(); //remove underscore to check the actual string length against max char value

			if (this.currentText_.length >= this.maxCharLength_) {
				if (goog.isDefAndNotNull(this.errorCallback_)) {
					this.errorCallback_();
				}
			} else {
				this.currentText_ += character;
				this.addUnderscore_();

				//Forces focus onto Enter button if email extension keys are pressed
				/*if (dtv.ui.Keyboard.NAVIGATION_KEY.indexOf(character) > - 1) {
					if (character != dtv.ui.Keyboard.DOT_COM_STRING) {
						this.currentText_ += dtv.ui.Keyboard.DOT_COM_STRING;
					}

					this.forceFocusEnterKey_();
				}*/

				this.showText_();
			}
			break;

	}
};

/**
 * Key handler for when 1-9 are pressed on the controller
 * functions similar to T9 texting on mobile phones
 * @param {!object} The key event to be handld
 */
dtv.ui.Keyboard.prototype.T9Keyhandler_ = function(key) {
	console.log("***Handling T9 style key entry***");

	clearTimeout(this.T9timeout);
	this.T9timeout = setTimeout(goog.bind(this.resetT9_, this), 2000);

	this.removeUnderscore_();

	if (this.currentText_.length >= this.maxCharLength_) {
		if (goog.isDefAndNotNull(this.errorCallback_)) {
			this.errorCallback_();
		}
	} else {
		if(this.prevKeyCode_ == key.keyCode) {
			this.T9Index_++;

			if(this.T9Index_ >= dtv.ui.Keyboard.T9_KEYS[key.keyCode].length) {
				this.T9Index_ = 0;
			}

			this.currentText_ = this.currentText_.substr(0, this.currentText_.length - 1) + dtv.ui.Keyboard.T9_KEYS[key.keyCode][this.T9Index_];
		} else {
			this.prevKeyCode_ = key.keyCode;
			this.T9Index_ = 0;
			this.currentText_ += dtv.ui.Keyboard.T9_KEYS[key.keyCode][this.T9Index_];
		}

		this.showText_();
	}
};

/**
 * Removes all underscores in a string
 * @private
 */
dtv.ui.Keyboard.prototype.removeUnderscore_ = function() {
	var regex = /_/g;

	if(regex.test(this.currentText_)) {
		this.currentText_ = this.currentText_.replace(regex, '');
	}
};

/**
 * Adds an underscore to the end of a string
 * @private
 */
dtv.ui.Keyboard.prototype.addUnderscore_ = function() {
	this.currentText_ += '_';
};

/**
 * Resets all T9 key handling properties, usually assigned to a timeout
 * @private
 */
dtv.ui.Keyboard.prototype.resetT9_ = function() {
	this.T9Index_ = 0;
	this.prevKeyCode_ = 0;
	this.removeUnderscore_();
	this.addUnderscore_();
	this.showText_();
};

/**
 * Returns the currently displayed text
 * @return {string} text that is currently displayed in text box
 */
dtv.ui.Keyboard.prototype.getText = function() {
	this.removeUnderscore_();
	return this.currentText_;
};

/**
 * Change the position and size of highlighter
 * @private
 */
dtv.ui.Keyboard.prototype.changeFocus_ = function() {
	var charData = dtv.ui.Keyboard.CONFIG[this.row_][this.col_];
	this.keyboardHLDom_.style.left = charData['position'][0] + 'px';
	this.keyboardHLDom_.style.top = charData['position'][1] + 'px';
	this.keyboardHLDom_.style.width = charData['size'][0] + 'px';
	this.keyboardHLDom_.style.height = charData['size'][1] + 'px';
	this.keyboardHLDom_.style.backgroundPosition = charData['spritePosition'][0] + "px " + charData['spritePosition'][1] + "px";
};

/**
 * Return the max column of current row
 * @param {number=} row The row need to get max col
 * @return {!number}
 * @private
 */
dtv.ui.Keyboard.prototype.getMaxCol_ = function(row) {
	row = (row == null ? this.row_ : row);
	if (row < 0 || row >= this.maxRow_) return -1;

	return dtv.ui.Keyboard.CONFIG[row].length;
};

/**
 * Show the text
 * @private
 */
dtv.ui.Keyboard.prototype.showText_ = function() {
	this.textField_.value = this.currentText_;
	this.textField_.scrollLeft = this.textField_.scrollWidth;
};

/**
 * Handle when the keyboard image is loaded
 * @private
 */
dtv.ui.Keyboard.prototype.handleKeyboardLoaded_ = function() {
	this.showHighlighter();
};

/**
 * Force focus to enter key
 * @private
 */
dtv.ui.Keyboard.prototype.forceFocusEnterKey_ = function() {
	this.row_ = 0;
	this.col_ = this.getMaxCol_() - 1;
	this.changeFocus_();
};

/** Enum for keyboard data*/
dtv.ui.Keyboard.CONFIG = [
	[
		{
			'value': '1',
			'position': [23, 110],
			'size': [62, 62],
			'spritePosition': [0, -4]

		},
		{
			'value': '2',
			'position': [98, 110],
			'size': [62, 62],
			'spritePosition': [-80, -4]
		},
		{
			'value': '3',
			'position': [171, 110],
			'size': [62, 62],
			'spritePosition': [-159, -4]
		},
		{
			'value': '4',
			'position': [246, 110],
			'size': [63, 62],
			'spritePosition': [-240, -4]
		},
		{
			'value': '5',
			'position': [322, 110],
			'size': [63, 62],
			'spritePosition': [-321, -4]
		},
		{
			'value': '6',
			'position': [396, 110],
			'size': [63, 62],
			'spritePosition': [-401, -4]
		},
		{
			'value': '7',
			'position': [472, 110],
			'size': [62, 62],
			'spritePosition': [-482, -4]
		},
		{
			'value': '8',
			'position': [543, 110],
			'size': [62, 62],
			'spritePosition': [-559, -4]
		},
		{
			'value': '9',
			'position': [619, 110],
			'size': [63, 62],
			'spritePosition': [-640, -4]
		},
		{
			'value': '0',
			'position': [691, 110],
			'size': [63, 62],
			'spritePosition': [-718, -4]
		}
	],
	[
		{
			'value': 'A',
			'position': [23, 188],
			'size': [62, 64],
			'spritePosition': [0,   -88]
		},
		{
			'value': 'B',
			'position': [97, 188],
			'size': [63, 64],
			'spritePosition': [-80, -88]
		},
		{
			'value': 'C',
			'position': [170, 188],
			'size': [63, 64],
			'spritePosition': [-159, -88]
		},
		{
			'value': 'D',
			'position': [246, 188],
			'size': [63, 64],
			'spritePosition': [-240, -88]
		},
		{
			'value': 'E',
			'position': [322, 188],
			'size': [63, 64],
			'spritePosition': [-321, -88]
		},
		{
			'value': 'F',
			'position': [396, 188],
			'size': [63, 64],
			'spritePosition': [-401, -88]
		},
		{
			'value': 'G',
			'position': [472, 188],
			'size': [62, 64],
			'spritePosition': [-482, -88]
		},
		{
			'value': 'H',
			'position': [543, 188],
			'size': [62, 64],
			'spritePosition': [-559, -88]
		},
		{
			'value': 'I',
			'position': [619, 188],
			'size': [62, 64],
			'spritePosition': [-640, -88]
		},
		{
			'value': 'J',
			'position': [691, 188],
			'size': [63, 64],
			'spritePosition': [-718, -88]
		}
	],
	[
		{
			'value': 'K',
			'position': [23, 265],
			'size': [62, 64],
			'spritePosition': [0,    -171]
		},
		{
			'value': 'L',
			'position': [98, 265],
			'size': [61, 64],
			'spritePosition': [-80,  -171]
		},
		{
			'value': 'M',
			'position': [171, 265],
			'size': [62, 64],
			'spritePosition': [-159, -171]
		},
		{
			'value': 'N',
			'position': [247, 265],
			'size': [62, 64],
			'spritePosition': [-240, -171]
		},
		{
			'value': 'O',
			'position': [322, 265],
			'size': [63, 64],
			'spritePosition': [-321, -171]
		},
		{
			'value': 'P',
			'position': [396, 265],
			'size': [63, 64],
			'spritePosition': [-401, -171]
		},
		{
			'value': 'Q',
			'position': [472, 265],
			'size': [62, 64],
			'spritePosition': [-482, -171]
		},
		{
			'value': 'R',
			'position': [543, 265],
			'size': [62, 64],
			'spritePosition': [-559, -171]
		},
		{
			'value': 'S',
			'position': [619, 265],
			'size': [62, 64],
			'spritePosition': [-640, -171]
		},
		{
			'value': 'T',
			'position': [691, 265],
			'size': [63, 64],
			'spritePosition': [-718, -171]
		}
	],
	[
		{
			'value': 'U',
			'position': [23, 345],
			'size': [62, 62],
			'spritePosition': [0,    -258]
		},
		{
			'value': 'V',
			'position': [98, 345],
			'size': [62, 62],
			'spritePosition': [-80,  -258]
		},
		{
			'value': 'W',
			'position': [171, 345],
			'size': [63, 62],
			'spritePosition': [-159, -258]
		},
		{
			'value': 'X',
			'position': [247, 345],
			'size': [62, 62],
			'spritePosition': [-240, -258]
		},
		{
			'value': 'Y',
			'position': [322, 345],
			'size': [63, 62],
			'spritePosition': [-321, -258]
		},
		{
			'value': 'Z',
			'position': [396, 345],
			'size': [63, 62],
			'spritePosition': [-401, -258]
		},
		{
			'value': '-',
			'position': [472, 345],
			'size': [62, 62],
			'spritePosition': [-482, -258]
		},
		{
			'value': 'clear',
			'position': [543, 345],
			'size': [62, 62],
			'spritePosition': [-559, -258]
		},
		{
			'value': ' ',
			'position': [619, 345],
			'size': [62, 62],
			'spritePosition': [-640, -258]
		},
		{
			'value': 'del',
			'position': [691, 345],
			'size': [63, 62],
			'spritePosition': [-718, -258]
		}
	]
];
