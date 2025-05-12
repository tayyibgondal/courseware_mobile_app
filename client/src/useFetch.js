import { useContext, useEffect, useState } from "react";

export default function useFetch(url) {
  const [data, setData] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      const response = await fetch(url);
      if (response.status === 200) {
        const data = await response.json();
        setData(data);
      }
      // COULD BE DONE - if doing server side authorization too
      // else if (response.status == 401) {
      //   navigator("/");
      // }
      else {
        alert("Could not fetch data!");
      }
    };
    fetchData();
  }, [url]);
  return { data, setData };
}
