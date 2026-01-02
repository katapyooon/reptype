import React from 'react';
import Likert from 'react-likert-scale';

const LikertScale = ({ question }) => {
  const likertOptions = {
    question: question.content,  // Railsから渡された質問文
    responses: [
      { value: 1, text: "Strongly Disagree" },
      { value: 2, text: "Disagree" },
      { value: 3, text: "Neutral" },
      { value: 4, text: "Agree" },
      { value: 5, text: "Strongly Agree" }
    ],
    onChange: val => {
      console.log(val);  // 回答を処理（後でRailsに送信）
    }
  };

  return <Likert {...likertOptions} />;
};

export default LikertScale;