module PlansHelper

  def networth_data
    [
      {name: "traffic", data: {"t1": 10532.32, "c1": 0,  "t2": 8900}},
      {name: "aws", data: {"c1": 6979.53, "c2": 4500}}, 
      {name: "idc", data: {"c1": 6979.53, "c2": 4500}}, 
    ]
  end

  def chart_data2
    {
        labels: ['Item 1', 'Item 2', 'Item 3'],
        datasets: [
            {
                type: 'bar',
                label: 'Bar Component',
                data: [10, 20, 30],
            },
            {
                type: 'line',
                label: 'Line Component',
                data: [30, 20, 10],
            }
        ]
    }
  end

end
