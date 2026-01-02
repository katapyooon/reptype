import React from 'react';
import LikertScale from './LikertScale';

const App = ({ question }) => {  // Railsからquestionをpropsとして渡す
  return (
    <div>
      <LikertScale question={question} />
    </div>
  );
};

export default App;