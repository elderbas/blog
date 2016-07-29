I'm currently working on a project that helps you parse e-books into datasets ready for analytic consumption. After working on my prototype version of [Game of Trends](https://gotrends.herokuapp.com) which is a tool for analyzing word frequency trends for words out of the Game of Thrones book series, I thought it'd be more fun to have a tool that you can search not only how often a specific word happens, but *who* says it.

That opened up even more ideas to being able to do sentiment analysis using APIs such as [IBM's Watson](https://developer.ibm.com/watson/) and do entire expression searches per person.

I realized I either needed to write a script that could fancily infer which character is speaking by context of the sentence arrangement, or I could read the book and and line by line cut and paste the text into:
```text
	Billy: 'Do you think you can win?'
	Narration: Billy said.
	Joe: 'Of course I can.'
```

Writing a script with that kind of logic seemed above me so I opted for outsourcing the job to a wonderful contractor on [Freelancer](https://www.freelancer.com/) who worked really hard on it. However, I imagine the task wasn't very fun, despite him saying he'd love to do it, and I ended up with the first book of Game of Thrones parsed similarly to the format just above, but it was riddled with errors and when I'd double check his work many times I found errors.

My first draft tool of this wasn't too bad. A quick prototype using mostly [jQuery](https://jquery.com/) resulted in a tool that you could click on the quoted text and you could select the name of a character already entered in and it would help build a version of the script up above. However, advice that has been given to me by one of the makers behind [Ziff](http://beehivestartups.com/blog/ziff-making-everyone-data-scientist/) suggested to incorporate "smarts" into any apps I make. I opted to help predict what the name would be for a given utterance in the book instead of having to select it manually from a dropdown list.

In order to start extracting names I saw a pattern of names generally being in capitals. If it were a full name it was a sequence of capitalized words. I decided to creating some unit tests for a function I thought could parse out sentences that were outside of spoken text.

```javascript
'use strict';
let expect = require('chai').expect;
let extractRunningCapitalWords = require('../src/extractRunningCapitalWords.js');

describe('extractRunningCapitalWords', () => {
  it('exists as a function', function () {
    expect(typeof extractRunningCapitalWords).to.equal('function');
  });

  it('extracts a single word cap', function () {
    expect(extractRunningCapitalWords('Bob')).to.deep.equal(['Bob']);
  });

  it('extracts multiple separate cap word expressions', function () {
    expect(extractRunningCapitalWords('Bob walked, but he saw Jane.')).to.deep.equal(['Bob', 'Jane']);
    expect(extractRunningCapitalWords('Bob, do not see Jane.')).to.deep.equal(['Bob', 'Jane']);
    expect(extractRunningCapitalWords('Bob. Jane is not here.')).to.deep.equal(['Bob', 'Jane']);
    expect(extractRunningCapitalWords('Bob, Jane is not here.')).to.deep.equal(['Bob', 'Jane']);
  });

  it('extracts a multi word name as one', function () {
    expect(extractRunningCapitalWords('Bob Jones, he saw a cat.')).to.deep.equal(['Bob Jones']);
    expect(extractRunningCapitalWords('Bob Jones saw a cat.')).to.deep.equal(['Bob Jones']);
  });

  it('isnt fooled by common pronouns', function () {

    expect(extractRunningCapitalWords('Bob Jones. He is cool.')).to.deep.equal(['Bob Jones']);
    expect(extractRunningCapitalWords('Bob and Jane. They are cool.')).to.deep.equal(['Bob','Jane']);
  });

  it('less common punctuation marks break in running name', () => {
    expect(extractRunningCapitalWords('Bob Jones - He is cool.')).to.deep.equal(['Bob Jones']);
    expect(extractRunningCapitalWords('Bob and Jane: They are cool.')).to.deep.equal(['Bob','Jane']);
    expect(extractRunningCapitalWords('Bob Jones: he is cool.')).to.deep.equal(['Bob Jones']);
    expect(extractRunningCapitalWords('Bob Jones; They are cool.')).to.deep.equal(['Bob Jones']);
  });

});//end describe('bookStorageFormat'
```

After passing the tests with
```javascript
'use strict';
let _ = require('lodash');

/*
* purpose - to get names out of sentences
*         - if a name is used as "Bob's", then it will be used as "Bob"
* */
function extractRunningCapitalWords(sentence) {
  let runningCapWords = [];
  if (_.isUndefined(sentence) || sentence.length && sentence.trim() === 0) { return runningCapWords; }
  // replace double white spaces with one
  let wordList = sentence.split(' ');
  let startIndexOfRunningWord = null, endIndexOfRunningWord = null;
  _.forEach(wordList, (word, i, arr) => {
    // word in question is capitalized
    let currWordIsCap = /[A-Z]/.test(word.charAt(0));
    // as long as we keep getting cap words in a row, keep setting the endIndex to the lastest
    if (currWordIsCap) {
      if (_.isNull(startIndexOfRunningWord)){
        startIndexOfRunningWord = endIndexOfRunningWord = i;
      }
      else {
        endIndexOfRunningWord = i;
      }
      // if the current range has any clause-ending punctuation, then name is done being formed
      if (/[,\.:;]/.test(arr[endIndexOfRunningWord])){
        runningCapWords.push(makeDirtyFullNameClean(arr.slice(startIndexOfRunningWord, endIndexOfRunningWord+1).join(' ')));
        startIndexOfRunningWord = endIndexOfRunningWord = null;
      }
    }
    else {
      if (!_.isNull(startIndexOfRunningWord)) {
        let wordToAddOn = arr.slice(startIndexOfRunningWord, endIndexOfRunningWord+1);
        runningCapWords.push(makeDirtyFullNameClean(wordToAddOn.join(' ')));
        startIndexOfRunningWord = endIndexOfRunningWord = null;
      }
    }
    // if we don't have a cap word, AND startIndex is NOT null, push that index range onto runningCapWords
  });

  if (!_.isNull(startIndexOfRunningWord) && !_.isNull(endIndexOfRunningWord)){
    let currentWordInRange = wordList.slice(startIndexOfRunningWord, endIndexOfRunningWord+1);
    runningCapWords.push(makeDirtyFullNameClean(currentWordInRange.join(' ')));
  }
  return filterCommonPronouns(runningCapWords);

  function makeDirtyFullNameClean(str) {
    if (/’s\b/.test(str)) {
      console.log('yayy');
    }
    return str;
    return str.replace(/[^A-z\s-]/g, '').trim();
  }
  function filterCommonPronouns (arr) {
    let pronouns = ['i', 'he', 'she', 'it', 'we', 'they'];
    return arr.filter((word) => {
      return !pronouns.includes(word.toLowerCase());
    });
  }
}

module.exports = extractRunningCapitalWords;
```

This worked great for the tests but when I started applying the function to my real data I started seeing mostly pieces of text that would hit true for running capital words like `Have I...` and tons of others that didn't occur to me at the time. I was thinking I'd have to start creating a hash of instances to ignore when I came across a library called [nlp_compromise](https://github.com/nlp-compromise/nlp_compromise) on GitHub. I noticed a feature where you could so something like:

```javascript
let nlp = require('nlp_compromise');
let listOfPeople = nlp.text(`Brian. Don't eat too much Captain Crunch.`).people();
console.log('listOfPeople', listOfPeople);
```

Which worked out great for simple names. I tested out some names I found in Game of Thrones and none of them hit as 'People' and sometimes not even nouns. Eventually I came across a section in the documentation where you can add your own words and assign it a specific Tag type (Person, Verb, Noun, or a custom named type like 'CherryOnTop'). This was perfect. I realized I could scan sentences around a given piece of speech text and use names already provided by the user and create Person tags for them by simply doing this before calling nlp.text() on anything

```javascript
let newLexicon = {};
let namesAddedByUser = ['Splittly Doop', 'Crazy Named Person'];
namesAddByUser.forEach((name) => {
  newLexicon[name] = 'PersonSelected';
});
nlp.lexicon(newLexicon);

// do other nlp.text() stuff now
```

Users would then be identified and tagged as `PersonSelected` tag type. I didn't want to just opt for `Person` which is the default type it assigns names it's identified, so I could distinguish more easily characters entered by the user. There's a lot more you can do with the JS library [nlp_compromise](https://github.com/nlp-compromise/nlp_compromise), but it's the main thing I'm using it for so far in my quest to create an e-book parsing tool.


























































