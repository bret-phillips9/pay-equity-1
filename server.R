server <- function(input, output, session){
     
     # read upload data into R
     CompData <- reactive({
          if (is.null(input$FileUpload)){
               return(NULL)
          } 
          
          read_csv(input$FileUpload$datapath)
     }) 
     
     # based on columns in upload data, present input controls in the UI
     # to let user select which columns represent the pay variable, the 
     # pay group variable, and the protected group status variable
     output$pay_ui <- renderUI({
          req(CompData())
          selectInput("PayCol", "Please choose pay column", choices = names(CompData()))
     })
     
     output$lvl_ui <- renderUI({
          req(CompData())
          selectInput("LevelCol", "Please choose pay group (title, grade, etc.) column", choices = names(CompData()))
     })
     
     output$grp_ui <- renderUI({
          req(CompData())
          selectInput("GroupCol", "Please choose protected status column", choices = names(CompData()))
     })
     
     # Once the protected group status variable is known,
     # ask the user to choose which value will be the focal group
     # this will be the group all other groups are contrasted against
     output$focal_ui <- renderUI({
          req(input$GroupCol)
          vals <- unique(CompData()[[input$GroupCol]])
          selectInput("FocalGrp", "Please select group of interest", choices = vals)
     })
     
     # return some feedback to user regarding which pay variable
     # is being analyzed, and for which focal group
     # this goes at the top of the second tab
     output$selection <- renderPrint({
          req(input$GroupCol, input$FocalGrp)
          cat("Analysis for disparity in", input$PayCol, "by grouping of", input$LevelCol, "\n")
          cat("Focal group for this analysis is", input$FocalGrp)
     })
     
     # can't repeat output$selection across multiple tabs so had to make a copy
     output$selection_copy <- renderPrint({
          req(input$GroupCol, input$FocalGrp)
          cat("Analysis for disparity in", input$PayCol, "by grouping of", input$LevelCol, "\n")
          cat("Focal group for this analysis is", input$FocalGrp)
     })
     
     # return a preview of the upload data to user on first tab
     output$tbl_ui <- renderTable({
          req(CompData())
          head(CompData(), n = 15)
     })
     
     # below is a series of reactive data steps that will transform
     # the upload data into the final ladder analysis table
     # to ensure proper calculation, pay will be explicitly cast as
     # numeric, and level will be explicitly cast as a factor
     ladder_df <- reactive({
          req(CompData())
          CompData() |> 
               mutate(group = ifelse(.data[[input$GroupCol]] == !!input$FocalGrp, 1, 0)) |> 
               mutate(grp_lbl = .data[[input$GroupCol]]) |> 
               mutate(level = as.factor(.data[[input$LevelCol]])) |> 
               mutate(pay = as.numeric(.data[[input$PayCol]])) |> 
               select(group, grp_lbl, level, pay) 
     })
     
     lvl_df <- reactive({
          req(ladder_df())
          ladder_df() |> 
               group_by(level) |> 
               summarize(n_ee = n(), 
                         n_focal = sum(group),
                         total_pay = sum(pay), 
                         avg_pay_total = mean(pay),
                         total_sum_sq = sum(pay^2)) |> 
               # sort the levels based on average pay
               arrange(avg_pay_total) |> 
               select(level, n_ee, n_focal, total_pay, avg_pay_total, total_sum_sq) |> 
               mutate(total_pay_sq = total_pay^2)
     })
     
     focal_df <- reactive({
          req(ladder_df())
          ladder_df() |> 
               filter(group == 1) |> 
               group_by(level) |> 
               summarize(focal_pay = sum(pay), 
                         avg_pay_focal = mean(pay),
                         focal_sum_sq = sum(pay^2)) |> 
               select(level, focal_pay, avg_pay_focal, focal_sum_sq) |> 
               mutate(focal_pay_sq = focal_pay^2)
     })
     
     t_test_tbl <- reactive({
          req(focal_df())
          lvl_df() |> 
               left_join(focal_df(), join_by(level)) |> 
               mutate(focal_pay = ifelse(n_focal == 0, 0, focal_pay)) |> 
               mutate(avg_pay_focal = ifelse(n_focal == 0, 0, avg_pay_focal)) |> 
               mutate(focal_sum_sq = ifelse(n_focal == 0, 0, focal_sum_sq)) |> 
               mutate(focal_pay_sq = ifelse(n_focal == 0, 0, focal_pay_sq)) |>
               mutate(n_other = n_ee - n_focal) |> 
               mutate(avg_disp = ifelse((n_focal == 0 | n_other == 0), 0, avg_pay_focal - ((total_pay - focal_pay)/(n_ee - n_focal)))) |> 
               mutate(ss_focal = ifelse(n_focal == 0, 0, focal_sum_sq - (focal_pay_sq/n_focal))) |> 
               mutate(var_focal = ifelse(n_focal == 0, 0, ss_focal/n_focal)) |> 
               mutate(other_sum_sq = total_sum_sq - focal_sum_sq) |> 
               mutate(other_pay_sq = (total_pay - focal_pay)^2) |> 
               mutate(ss_other = ifelse(n_other == 0, 0, other_sum_sq - (other_pay_sq/n_other))) |> 
               mutate(var_other = ifelse(n_other == 0, 0, ss_other/n_other)) |> 
               # minimum size: both groups must have at least 2 people to ensure adequate df
               mutate(t_test = ifelse((n_focal > 1 & n_other > 1), avg_disp/(sqrt(var_focal + var_other)), NA)) |> 
               mutate(t_df = n_focal + n_other - 2) |> 
               mutate(t_prob = pt(t_test, t_df)) |> 
               # pt is cumulative, so for top end subtract 1 to focus on area in tail
               mutate(t_prob = ifelse(t_prob > .5, 1 - t_prob, t_prob))
     })
     
     # need to also do a marginal t-test for the total dataset
     marginal_tbl <- reactive({
          req(t_test_tbl())
          t_test_tbl() |> 
               summarize(n_ee = sum(n_ee),
                         n_focal = sum(n_focal),
                         n_other = sum(n_other),
                         focal_pay = sum(focal_pay),
                         total_pay = sum(total_pay),
                         focal_sum_sq = sum(focal_sum_sq),
                         other_sum_sq = sum(other_sum_sq)) |> 
               mutate(focal_pay_sq = focal_pay^2) |> 
               mutate(avg_pay_total = total_pay/n_ee) |> 
               mutate(avg_pay_focal = focal_pay/n_focal) |> 
               mutate(avg_disp = ifelse((n_focal == 0 | n_other == 0), 0, avg_pay_focal - ((total_pay - focal_pay)/(n_ee - n_focal)))) |> 
               mutate(ss_focal = ifelse(n_focal == 0, 0, focal_sum_sq - (focal_pay_sq/n_focal))) |> 
               mutate(var_focal = ifelse(n_focal == 0, 0, ss_focal/n_focal)) |> 
               mutate(other_pay_sq = (total_pay - focal_pay)^2) |> 
               mutate(n_other = n_ee - n_focal) |> 
               mutate(ss_other = ifelse(n_other == 0, 0, other_sum_sq - (other_pay_sq/n_other))) |> 
               mutate(var_other = ifelse(n_other == 0, 0, ss_other/n_other)) |> 
               # minimum size: here both groups must have at least 5 people to ensure adequate df
               mutate(t_test = ifelse((n_focal > 4 & n_other > 4), avg_disp/(sqrt(var_focal + var_other)), NA)) |> 
               mutate(t_df = n_focal + n_other - 2) |> 
               mutate(t_prob = pt(t_test, t_df)) |> 
               # pt is cumulative, so for top end subtract 1 to focus on area in tail
               mutate(t_prob = ifelse(t_prob > .5, 1 - t_prob, t_prob)) |> 
               mutate(level = "TOTAL")
     })
     
     final_tbl <- reactive({
          req(marginal_tbl())
          t_test_tbl() |> 
               bind_rows(marginal_tbl()) |> 
               select(level, n_ee, n_focal, avg_pay_focal, avg_disp, t_test, t_prob) 
               
     })
     
     # finally, return the analysis table to the Analysis Table tab
     ladder_ui <- reactive({
          req(final_tbl())
          datatable(final_tbl(), 
                    colnames = c('Level', '# EEs', paste('#', input$FocalGrp), paste(input$FocalGrp, 'Avg. Pay'), 
                                 'Avg. Disparity', 't-Test', 'p-value'),
                    rownames = FALSE,
                    options = list(scrollX = TRUE)) |> 
               formatCurrency(c('avg_pay_focal', 'avg_disp')) |> 
               formatRound(c('t_test', 't_prob'), digits = 3) |> 
               formatStyle('t_test',
                           color = styleInterval(c(-1.96, 1.96), c('red', 'black', 'blue')))
     })
     
     graph_tbl <- reactive({
          req(final_tbl())
          
          final_tbl() |> 
               mutate(color_group = ifelse(avg_disp < 0, "negative", "positive")) |> 
               mutate(avg_pay_other = avg_pay_focal - avg_disp) |> 
               mutate(pct_underpaid = 100* (avg_disp/avg_pay_other)) |> 
               mutate(hjust = ifelse(pct_underpaid < 0, -0.25, 1.25))
     })
     
     graph_ui <- reactive({
          req(graph_tbl())
          
          # for readability, set dynamic x-axis scale limits
          scale_max <- graph_tbl() |> 
               summarize(scale_max = max(abs(pct_underpaid))) |> 
               mutate(scale_min = -1 * scale_max)
          
          ggplot(data = graph_tbl(), aes(x = pct_underpaid, y = level, fill = color_group)) +
               ggtitle("Pay Equity Analysis: % Disparity by Group") +
               geom_bar(stat = "identity") +
               geom_text(aes(label = paste(format(pct_underpaid, digits = 3), "%"), 
                             hjust = hjust,
                             fontface = "bold")) +
               ylab(input$LevelCol) +
               xlab(paste("%", input$FocalGrp, "Underpaid/Overpaid")) +
               scale_x_continuous(limits = c(scale_max$scale_min, scale_max$scale_max)) +
               geom_vline(xintercept = 0) +
               scale_fill_manual(values = c("negative" = "palevioletred", "positive" = "grey50")) +
               guides(fill = FALSE)
     })
     
     output$DownloadTable <- renderDT({
          print(ladder_ui())
     })
     
     output$DownloadPlot <- renderPlot({
          print(graph_ui())
     })
     
     output$Report <- downloadHandler(
          filename = function() { "My Pay Equity Report.pdf" },
          content = function(file) {
               showModal(modalDialog("Downloading...", footer=NULL))
               on.exit(removeModal())
               
               # Render PDF from Rmd with the table as a parameter
               rmarkdown::render(
                    input = "Report.Rmd",
                    output_file = "My Pay Equity Report.pdf",
                    params = list(table = final_tbl(),
                                  graph = graph_tbl(),
                                  focal = input$FocalGrp,
                                  level = input$LevelCol),
                    envir = new.env(parent = globalenv())
               )
               file.copy("My Pay Equity Report.pdf", file)
          }
     )
}

